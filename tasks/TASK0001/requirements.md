# Requirements — TASK0001

## Original request
Crear un boton en la pantalla que si lo aprieto me muestra un modal con el horaria actual pero en Central time.

## Goal
Agregar una acción interactiva en la pantalla de bienvenida para consultar la hora actual en la zona horaria de Centroamérica/Chicago según la configuración del usuario.

## Scope
### In scope
- Mantener la pantalla de bienvenida actual.
- Agregar un botón dentro de la pantalla.
- Mostrar un modal cuando se presiona el botón.
- Mostrar la hora actual en la zona horaria de Central Time.

### Out of scope
- Cambios de navegación o nuevas pantallas.
- Integración con backend o APIs externas.
- Otras zonas horarias.

## Acceptance criteria
- [x] La pantalla principal muestra un botón visible.
- [x] Al presionar el botón se abre un modal.
- [x] El modal muestra la hora actual en Central Time.
- [x] La aplicación sigue compilando correctamente.

## Constraints and dependencies
- La app se ejecuta con React + Vite.
- La zona horaria debe respetar `America/Chicago`.

## Questions and answers
| # | Question | Answer | Impact |
|---|---|---|---|
| 1 | ¿La zona horaria requerida es Central Time (EE. UU.)? | Sí, `America/Chicago` | High |

## Approval gate
- **Required:** Not required for this routine UI task.
- **Reason:** Small, local, low-risk change that does not alter contracts or architecture.
- **Decision:** Approved by orchestrator and implementation owner.
- **Approved by / date:** Copilot / 2026-11-06
- **Approved scope:** Button + modal with current time in Central Time.
