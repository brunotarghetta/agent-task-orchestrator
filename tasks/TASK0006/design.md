# Design — TASK0006

## Architecture decision — 2026-11-06
The system architect recommends an explicit lightweight mode, with the existing full mode as default. Keep the task directory and branch; create a single README record from a separate template. Select based on bounded scope and risk, escalate without overwriting the original record when needed, and preserve all existing approval and independent-review rules. Use isolated mocked tests for both modes and safety. This approach is accepted within the user's approved scope.

## Architecture review
- **Required:** Yes
- **Architect recommendation:** Explicit lightweight mode with full mode as default and safe escalation, as described above.

## Decision
Accept the recommendation above.

## Options and tradeoffs
Explicit selection avoids unreliable automatic classification; preserving the directory avoids disrupting existing task conventions.

## Compatibility, migration, and operations
Existing full-mode invocation remains the default. Existing task records need no migration.

## Approval
- **User approval required:** Yes
- **Decision and date:** Implementation approved, 2026-11-06; publication approval remains separate.
