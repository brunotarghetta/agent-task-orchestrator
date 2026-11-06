#!/usr/bin/env bash
set -euo pipefail

usage() { echo 'Usage: scripts/newtask.sh [--lightweight] "task description"' >&2; exit 2; }
[[ $# -ge 1 ]] || usage
mode=full
if [[ "$1" == --lightweight ]]; then
  mode=lightweight
  shift
fi
[[ $# -ge 1 && -n "$*" ]] || usage

detect_python() {
  local candidates=()

  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    case "$line" in
      *WindowsApps*) continue ;;
      *) candidates+=("$line") ;;
    esac
  done < <(where.exe python 2>/dev/null || true)

  if ((${#candidates[@]} > 0)); then
    echo "${candidates[0]}"
    return 0
  fi

  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    case "$line" in
      *WindowsApps*) continue ;;
      *) candidates+=("$line") ;;
    esac
  done < <(where.exe python3 2>/dev/null || true)

  if ((${#candidates[@]} > 0)); then
    echo "${candidates[0]}"
    return 0
  fi

  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    case "$line" in
      *WindowsApps*) continue ;;
      *) candidates+=("$line") ;;
    esac
  done < <(where.exe py 2>/dev/null || true)

  if ((${#candidates[@]} > 0)); then
    echo "${candidates[0]}"
    return 0
  fi

  echo 'Python is required but a valid installation was not found.' >&2
  exit 1
}

PYTHON_BIN="$(detect_python)"
description="$*"
repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo 'Run inside a Git repository.' >&2; exit 1; }
cd "$repo_root"
command -v gh >/dev/null || { echo 'GitHub CLI (gh) is required.' >&2; exit 1; }
gh auth status >/dev/null 2>&1 || { echo 'Authenticate with GitHub CLI first: gh auth login' >&2; exit 1; }
repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)" || { echo 'Could not resolve GitHub repository. Check origin and gh access.' >&2; exit 1; }
base_branch="${TASK_BASE_BRANCH:-main}"
git fetch origin "$base_branch" --quiet || { echo "Could not fetch origin/$base_branch" >&2; exit 1; }
base_sha="$(git rev-parse "origin/$base_branch^{commit}")"

# Check the commit that will be checked out, not the current working tree.
if [[ "$mode" == lightweight ]]; then
  required_templates=(tasks/lightweight-template/README.md)
else
  required_templates=(tasks/templates/{README,requirements,plan,context,design,review,status}.md)
fi
for template in "${required_templates[@]}"; do
  template_type="$(git cat-file -t "$base_sha:$template" 2>/dev/null)" || template_type=''
  [[ "$template_type" == blob ]] || { echo "Required $mode template $template is missing from base origin/$base_branch ($base_sha); no branch was created." >&2; exit 1; }
done

# Use both the checked-out repository and GitHub's remote refs to avoid reusing an ID.
declare -A used=()
shopt -s nullglob
for path in tasks/TASK[0-9]*; do
  name="${path##*/}"
  if [[ "$name" =~ ^TASK([0-9]+)$ ]]; then used["$((10#${BASH_REMATCH[1]}))"]=1; fi
done
remote_refs="$(git ls-remote --heads origin 'feature/task*')" || { echo 'Could not list remote task branches; refusing to allocate an ID.' >&2; exit 1; }
while IFS= read -r ref; do
  [[ -n "$ref" ]] || continue
  name="${ref##*/}"
  if [[ "$name" =~ ^task([0-9]+)$ ]]; then used["$((10#${BASH_REMATCH[1]}))"]=1; fi
done < <(printf '%s\n' "$remote_refs" | awk '{sub("refs/heads/feature/", "", $2); print $2}')

id=1
while [[ -n "${used[$id]+x}" ]]; do ((id+=1)); done
task_id="TASK$(printf '%04d' "$id")"
suffix="task$(printf '%04d' "$id")"
branch="feature/$suffix"
task_dir="tasks/$task_id"
[[ ! -e "$task_dir" ]] || { echo "$task_dir already exists; refusing to overwrite." >&2; exit 1; }

# Create the GitHub branch via the GitHub REST Git References API.
gh api --method POST "repos/$repo/git/refs" -f "ref=refs/heads/$branch" -f "sha=$base_sha" >/dev/null || { echo "GitHub could not create $branch. No local task files were created." >&2; exit 1; }

git fetch origin "$branch" --quiet
git switch --create "$branch" --track "origin/$branch" >/dev/null
for template in "${required_templates[@]}"; do
  [[ -f "$template" ]] || { echo "Required template $template is unavailable after checkout; the remote branch may already exist." >&2; exit 1; }
done
mkdir "$task_dir" || { echo "$task_dir could not be created safely; refusing to overwrite. The remote branch may already exist." >&2; exit 1; }
today="$(date +%F)"
short_title="$(printf '%s' "$description" | tr '
' ' ' | cut -c1-72)"
templates=(tasks/templates/*.md)
if [[ "$mode" == lightweight ]]; then
  templates=(tasks/lightweight-template/README.md)
fi
for template in "${templates[@]}"; do
  [[ -f "$template" ]] || { echo "Template $template is unavailable after checkout; the remote branch may already exist." >&2; exit 1; }
  target="$task_dir/${template##*/}"
  TASK_ID="$task_id" BRANCH_SUFFIX="$suffix" TASK_DATE="$today" \
    SHORT_TITLE="$short_title" TASK_DESCRIPTION="$description" \
    "$PYTHON_BIN" - "$template" "$target" <<'PYTEMPLATE'
from pathlib import Path
import os, sys
source, target = map(Path, sys.argv[1:])
text = source.read_text(encoding="utf-8")
values = {
    "{{TASK_ID}}": os.environ["TASK_ID"],
    "{{BRANCH_SUFFIX}}": os.environ["BRANCH_SUFFIX"],
    "{{DATE}}": os.environ["TASK_DATE"],
    "{{SHORT_TITLE}}": os.environ["SHORT_TITLE"],
    "{{DESCRIPTION}}": os.environ["TASK_DESCRIPTION"],
}
for marker, value in values.items():
    text = text.replace(marker, value)
target.write_text(text, encoding="utf-8")
PYTEMPLATE
done
printf 'Created %s on GitHub and checked it out locally. Task record: %s/
' "$branch" "$task_dir"
printf 'No commit or push was made. Review the task record, then follow .agents/orchestrator.md.
'
