#!/usr/bin/env bash
set -euo pipefail

usage() { echo 'Usage: scripts/newtask.sh "task description"' >&2; exit 2; }
[[ $# -ge 1 ]] || usage

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

# Use both the checked-out repository and GitHub's remote refs to avoid reusing an ID.
declare -A used=()
shopt -s nullglob
for path in tasks/TASK[0-9]*; do
  name="${path##*/}"
  if [[ "$name" =~ ^TASK([0-9]+)$ ]]; then used["$((10#${BASH_REMATCH[1]}))"]=1; fi
done
while IFS= read -r ref; do
  [[ -n "$ref" ]] || continue
  name="${ref##*/}"
  if [[ "$name" =~ ^task([0-9]+)$ ]]; then used["$((10#${BASH_REMATCH[1]}))"]=1; fi
done < <(git ls-remote --heads origin 'feature/task*' | awk '{sub("refs/heads/feature/", "", $2); print $2}')

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
mkdir -p "$task_dir"
today="$(date +%F)"
short_title="$(printf '%s' "$description" | tr '
' ' ' | cut -c1-72)"
for template in tasks/templates/*.md; do
  [[ -f "$template" ]] || continue
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
