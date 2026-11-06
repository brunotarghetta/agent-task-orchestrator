# Development task workflow

## Task layout

```text
.agents/
  orchestrator.md
  developer.md
  code-reviewer.md
  system-architect.md
scripts/newtask.sh
tasks/
  TASKXXXX/
    README.md
    requirements.md
    plan.md
    context.md
    design.md
    review.md
    status.md
```

Each task folder and its code live on the same `feature/taskXXXX` branch. The setup script creates the branch on GitHub using the GitHub CLI (`gh`) and checks it out locally. It does not commit or push task files.

Full mode uses the layout above. Explicit lightweight mode instead creates only `tasks/TASKXXXX/README.md` from a separate template. It contains the request, scope and criteria, short plan, decisions and approvals, checks, independent review, and status.

## Intake and branch creation

Invoke `/newtask <description>` in the agent host. The host should execute `scripts/newtask.sh "<description>"` at the repository root, then continue using `.agents/orchestrator.md`. Slash-command registration is host-specific; this repository provides the command's workflow and script, not a universal slash-command runtime.

For a clear, localized, bounded and low-risk task, the orchestrator may explicitly select `scripts/newtask.sh --lightweight "<description>"`. Full mode remains the default; neither mode changes approval requirements. If scope, risk, ambiguity or an architecture question grows, pause and escalate to the full process on the same branch and ID. Preserve the original README and its history, add needed full-record documents without overwriting it, record the escalation, and obtain any newly required approval before proceeding.

The script resolves the GitHub repository from `gh`/git configuration, uses `TASK_BASE_BRANCH` (default `main`), scans existing `tasks/TASK####` directories and remote `feature/task####` branches, selects the lowest unused positive number padded to four digits, and creates that remote branch from the base branch's current commit. It fetches and checks out the branch locally, then creates the task folder from templates. If the task workspace already exists, it fails safely.

The user should commit and push the task record through the normal project workflow. Branch creation on GitHub requires `gh` authentication and write permission for repository refs.

## Clarification and approval gate

At the start of intake, explain the two separate decisions: approval to implement when required, and approval to commit, push, and open a PR. The latter is requested only after the task is ready; implementation approval or an earlier publication preference does not authorize finalization.

The orchestrator records the request, asks only questions that materially affect scope or correctness, and records answers. It must request explicit user approval before implementation for architecture changes, contract changes, externally observable behavior changes, database migrations, or materially ambiguous requirements. It presents scope, acceptance criteria, and relevant risks. The approval is recorded in `requirements.md` and `status.md`, or in the lightweight README.

For clear routine work, implementation may begin without a separate approval pause. Creating the task branch and documents is intake work and may happen before approval; implementation may not.

## Implementation, architecture, and review

The orchestrator owns lifecycle coordination. It handles small localized changes or delegates larger work to the developer. Architecture questions go to the architect before coding; recommendations and accepted decisions are recorded. The independent reviewer receives the full diff and criteria and returns either `APPROVED` or `CHANGES REQUESTED` with actionable findings. Review depth may be proportional to the scope and risk, including in lightweight mode, but independence and the decision are still required. Requested changes return to the implementation owner, followed by another review.

## Completion

Complete only when acceptance criteria are met, required checks have passed or limitations are explicitly accepted, and review is approved. Record checks, review outcome, known limitations, and completion date in the task files.

After explicit user approval, the orchestrator may finalize the work by committing the approved changes and opening a pull request to the repository's main branch. This step is intentionally separate from implementation and must only happen after the task is ready and the approval is recorded.

The exact finalization flow is:
1. Confirm the working tree contains only the approved task changes.
2. Create a commit with a clear summary of the task outcome.
3. Push the task branch to origin.
4. Open a pull request targeting `main`.
5. Record the PR link and merge status in the task record.

This repository includes the helper script `scripts/complete-task.sh`, which automates the final step once the user approval is in place:

```bash
scripts/complete-task.sh "task completion summary" "PR title"
```

The script checks that the current branch is a task branch, commits local changes if needed, pushes the branch, and opens a PR to `main`. Merge, PR creation, deployment, and push still require the user’s explicit approval at the end of the task lifecycle unless repository policy separately authorizes them.
