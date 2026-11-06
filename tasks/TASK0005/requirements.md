# Requirements — TASK0005

## Original request
Aclarar al inicio del workflow las decisiones de aprobación de implementación y publicación, manteniendo la confirmación final separada.

## Goal
Clarify the two approval decisions at intake while retaining a separate final publication confirmation.

## Scope
### In scope
- Explain implementation approval and later publication approval at task intake.
- Preserve the requirement for explicit final approval after the task is ready.

### Out of scope
- Changing when approval is required or permitting advance publication authorization.

## Acceptance criteria
- [x] Intake instructions explain the two distinct decisions and identify commit, push, and PR creation as publication.
- [x] The workflow requires explicit publication approval after readiness; earlier preferences or implementation approval do not authorize it.
- [x] Orchestrator instructions and workflow documentation agree.

## Constraints and dependencies
- None recorded yet.

## Questions and answers
| # | Question | Answer | Impact |
|---|---|---|---|
| 1 | Advance conditional publication authorization or separate final confirmation? | Separate final confirmation. | Preserve the existing final gate. |

## Approval gate
- **Required:** Yes
- **Reason:** Workflow behavior change.
- **Decision:** Approved by user.
- **Approved by / date:** User, 2026-11-06
- **Approved scope:** Clarify the two decisions at intake while keeping final publication confirmation separate.
