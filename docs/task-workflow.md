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

## Intake and branch creation

Invoke `/newtask <description>` in the agent host. The host should execute `scripts/newtask.sh "<description>"` at the repository root, then continue using `.agents/orchestrator.md`. Slash-command registration is host-specific; this repository provides the command's workflow and script, not a universal slash-command runtime.

The script resolves the GitHub repository from `gh`/git configuration, uses `TASK_BASE_BRANCH` (default `main`), scans existing `tasks/TASK####` directories and remote `feature/task####` branches, selects the lowest unused positive number padded to four digits, and creates that remote branch from the base branch's current commit. It fetches and checks out the branch locally, then creates the task folder from templates. If the task workspace already exists, it fails safely.

The user should commit and push the task record through the normal project workflow. Branch creation on GitHub requires `gh` authentication and write permission for repository refs.

## Clarification and approval gate

The orchestrator records the request, asks only questions that materially affect scope or correctness, and records answers. It must request explicit user approval before implementation for architecture changes, contract changes, externally observable behavior changes, database migrations, or materially ambiguous requirements. It presents scope, acceptance criteria, and relevant risks. The approval is recorded in `requirements.md` and `status.md`.

For clear routine work, implementation may begin without a separate approval pause. Creating the task branch and documents is intake work and may happen before approval; implementation may not.

## Implementation, architecture, and review

The orchestrator owns lifecycle coordination. It handles small localized changes or delegates larger work to the developer. Architecture questions go to the architect before coding; recommendations and accepted decisions are recorded. The reviewer receives the full diff and criteria and returns either `APPROVED` or `CHANGES REQUESTED` with actionable findings. Requested changes return to the implementation owner, followed by another review.

## Completion

Complete only when acceptance criteria are met, required checks have passed or limitations are explicitly accepted, and review is approved. Record checks, review outcome, known limitations, and completion date in the task files. Merge, PR creation, deployment, and push require an explicit user request unless repository policy separately authorizes them.
