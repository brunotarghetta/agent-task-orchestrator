---
mode: agent
description: Crear una nueva tarea siguiendo el workflow del repositorio
---

# New task

Crea una nueva tarea en este repositorio usando el workflow definido por `scripts/newtask.sh`.

Pasos exactos:
1. Comprueba que estás en la raíz del repositorio.
2. Ejecuta este comando desde la raíz:
   `bash ./scripts/newtask.sh "${input:taskDescription}"`
3. Si el comando falla, reporta el error exacto y no intentes crear una tarea local de forma manual.
4. Una vez creada, explica:
   - el número de la tarea
   - la rama creada
   - la carpeta creada en `tasks/`
   - el siguiente paso recomendado

Si el usuario no proporciona una descripción, pídele una antes de ejecutar el comando.
