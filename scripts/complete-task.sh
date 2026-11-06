#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo 'Usage: scripts/complete-task.sh ["commit message"] ["pr title"]' >&2
  exit 2
}

if [[ $# -gt 2 ]]; then
  usage
fi

repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo 'Run inside a Git repository.' >&2
  exit 1
}

cd "$repo_root"

if ! command -v gh >/dev/null 2>&1; then
  echo 'GitHub CLI (gh) is required.' >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo 'Authenticate with GitHub CLI first: gh auth login' >&2
  exit 1
fi

current_branch="$(git branch --show-current)"
if [[ "$current_branch" != feature/task* ]]; then
  echo "This script must run from a task branch such as feature/task0001." >&2
  exit 1
fi

base_branch="${TASK_BASE_BRANCH:-main}"
if ! git show-ref --verify --quiet "refs/remotes/origin/$base_branch"; then
  git fetch origin "$base_branch" --quiet
fi

if [[ -n "$(git status --porcelain)" ]]; then
  commit_message="${1:-feat: complete task on $current_branch}"
  git add -A
  git commit -m "$commit_message" >/dev/null
else
  commit_message="${1:-chore: complete task on $current_branch}"
fi

git push origin "$current_branch" >/dev/null

pr_title="${2:-${commit_message}}"
pr_body="${TASK_PR_BODY:-## Summary
- Approved task completed.
- Changes are ready for review against \\$base_branch.

## Validation checklist
- [ ] Task requirements reviewed and match the final implementation.
- [ ] Relevant build/test checks were run successfully.
- [ ] No blocking issues remain in the task record.
- [ ] User approval was obtained before finalization.
- [ ] PR is ready for merge after review.

## Notes
- Branch: \\$current_branch
- Target branch: \\$base_branch
- Commit summary: \\$commit_message
}"

gh pr create \
  --base "$base_branch" \
  --head "$current_branch" \
  --title "$pr_title" \
  --body "$pr_body"

printf 'Completed task branch %s and opened a pull request to %s.\n' "$current_branch" "$base_branch"
