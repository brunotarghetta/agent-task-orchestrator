# Requirements — TASK0006

## Original request
Implementar un flujo ligero para tareas pequeñas: registro único, planificación breve y revisión proporcional, preservando las aprobaciones y la revisión independiente.

## Goal
Introduce a lightweight workflow for bounded, low-risk tasks without weakening approval or review gates.

## Scope
### In scope
- Add an explicit lightweight setup mode with one task-record file and a short plan.
- Document selection, escalation, proportional independent review, and preserved approval gates.
- Preserve the existing full workflow and invocation.

### Out of scope
- Relaxing publication approval, merging, or changing existing tasks.

## Acceptance criteria
- [x] Lightweight setup produces a single record in the normal task directory and retains branch and ID safety.
- [x] Default setup remains compatible with the full workflow.
- [x] Instructions define eligibility, escalation, independent review, and both approval gates.
- [x] Relevant automated checks cover both modes and safety behavior.

## Constraints and dependencies
- None recorded yet.

## Questions and answers
| # | Question | Answer | Impact |
|---|---|---|---|
| 1 | Publication approval timing? | User previously required a separate final confirmation. | No advance publication authorization. |

## Approval gate
- **Required:** Yes
- **Reason:** Workflow and script behavior change.
- **Decision:** Approved by user.
- **Approved by / date:** User, 2026-11-06
- **Approved scope:** Implement the proposed lightweight workflow with a single record and brief plan, preserving independent review and approval gates.
