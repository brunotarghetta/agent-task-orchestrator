# Design — TASK0001

## Architecture review
- **Required:** No
- **Architect recommendation:** Not required

## Decision
Use local React state for the modal and `Intl.DateTimeFormat` with the `America/Chicago` time zone to render the current time.

## Options and tradeoffs
- Option A: use a static string at click time — simplest, low risk.
- Option B: keep a real-time clock while the modal is open — slightly more code, but better matches “current time”.

The app uses Option B to keep the displayed time updated while the modal is open.

## Compatibility, migration, and operations
No migration or backend change is needed.

## Approval
- **User approval required:** No
- **Decision and date:** Approved in task intake; 2026-11-06
