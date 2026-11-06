# Agent task orchestration starter

This bundle provides repository instructions, role prompts, task templates, and a GitHub-backed task branch setup script for the workflow discussed.

## Install into a project
Copy `AGENTS.md`, `.agents/`, `docs/task-workflow.md`, `tasks/templates/`, `tasks/lightweight-template/`, and `scripts/newtask.sh` into the repository root. Make the script executable:

```bash
chmod +x scripts/newtask.sh
```

Add the real build/test/lint commands to `AGENTS.md`. Confirm the default base branch (`main`) or set `TASK_BASE_BRANCH` to the repository's intended base branch. Commit and push the installed files, including both template directories, to that base branch before creating tasks: the setup script checks the remote base commit for the selected mode's templates.

## Start a task

The agent host receives `/newtask <description>`. It should invoke:

```bash
scripts/newtask.sh "description of the task"
```

The script requires Git, GitHub CLI (`gh`), an authenticated GitHub account, repository read access, and permission to create branches. It finds the first free numeric ID among `tasks/TASK####` directories and GitHub `feature/task####` branches. It creates the branch on GitHub from the base branch, checks it out locally, and creates `tasks/TASK####/` from the templates.

The script creates the branch remotely via GitHub's Git References API through `gh`; it does not create a local-only branch first. It does not commit or push the task record. The slash command itself must be wired to this script by the chosen agent host because slash-command registration differs across tools.

## Then follow the workflow

The orchestrator reads `.agents/orchestrator.md`, completes task context and clarification, requests approval for the agreed high-impact triggers, implements or delegates, and requires independent review. See `docs/task-workflow.md` for the lifecycle and `AGENTS.md` for shared project rules.

When a task has received explicit user approval and all checks have passed, the finalization step is:

```bash
bash ./scripts/complete-task.sh "Approved task completion" "PR title"
```

This commits the approved work, pushes the task branch, and creates a pull request against `main`.

## Safety and concurrency note

The script checks both the current checkout's task folders and GitHub branch names. If two people create tasks concurrently, both can choose the same next ID; GitHub rejects the second branch creation, and the script stops without overwriting files. Rerun after the first task is visible to obtain the next available ID.
