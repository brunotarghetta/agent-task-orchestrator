# Requirements — TASK0003

## Original request
Crear un nuevo boton en la pantalla principal y que me muestre un popup con la hora actual en Egipto.

## Goal
Añadir una segunda acción desde la pantalla de bienvenida para abrir un popup con la hora actual en la zona horaria de Egipto, manteniendo la funcionalidad de hora central existente.

## Scope
### In scope
- Agregar un nuevo botón en la pantalla principal.
- Abrir un modal con la hora actual en Egipto.
- Mantener el botón y modal actual de Central Time.
- Actualizar la vista con estilos sencillos para los botones.

### Out of scope
- Cambios de infraestructura o backend.
- Añadir más pantallas o navegación.

## Acceptance criteria
- [x] Se visualiza un botón adicional en la pantalla principal.
- [x] Al hacer clic en ese botón se abre un popup/modal.
- [x] El popup muestra la hora actual en Egipto.
- [x] La hora se actualiza en tiempo real mientras el modal está abierto.
- [x] El botón de Central Time continúa funcionando.

## Constraints and dependencies
- React app existente en src.
- Uso de Intl.DateTimeFormat para convertir zonas horarias.

## Questions and answers
| # | Question | Answer | Impact |
|---|---|---|---|
| 1 | ¿Se debe conservar la funcionalidad anterior? | Sí, se mantiene la hora de Central Time y se añade la de Egipto. | La solución implementa dos zonas horarias en un solo modal dinámico. |

## Approval gate
- **Required:** Yes
- **Reason:** Validation build succeeded and the feature matches the requested UX.
- **Decision:** Approved
- **Approved by / date:** User approval on 2026-11-06
- **Approved scope:** Add the Egypt time popup while keeping the existing Central Time button working.
