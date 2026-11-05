---
name: cerrar
description: Cerrar una sesión de Sector Cero - bitácora de la sesión, estado al día, commit, push de la rama y su Pull Request. Úsalo cuando Adam o Alan digan «ya he acabado», «cierra la sesión» o «no me queda más tiempo».
---

# Cerrar la sesión

Esta orden autoriza el push de la rama de la tarea y abrir o poner al día su
PR, sin preguntar. **Nunca** autoriza fusionar en `main`, subir a `main`
directamente ni subir etiquetas.

1. **Bitácora**: un fichero nuevo en `documentacio/bitacora/`, llamado
   `AAAA-MM-DD_persona_tema.md`, con el formato de los anteriores:
   - qué se ha hecho
   - decisiones técnicas y por qué (y las de la persona, con sus palabras)
   - cambios de rumbo, problemas y solución
   - uso de IA y métodos de test
   - estado al cerrar y siguiente paso
   - **horas**: preguntarlas y sumar a las acumuladas de la última entrada
2. **Estado**: lo que toque en `documentacio/requisitos_y_estado.md` y las
   casillas de `documentacio/planificacion.md`.
3. `/validar` si se ha tocado código.
4. **Commit** solo de lo de esta sesión, con la convención de
   `documentacio/flujo_de_trabajo.md`. Si Godot ha reescrito ficheros que no
   se han tocado, `git restore` y avisar.
5. `git push -u origin <rama>`.
6. **PR**: si no existe, `gh pr create --base main` con un resumen de qué
   cambia y cómo se ha probado; si existe, comprobar que el push lo ha puesto
   al día (`gh pr view`).
7. Decir en una línea qué rama y qué PR quedan, y si la comprobación de la
   Action está en verde. Si el PR está listo y el otro ya lo ha revisado, la
   persona puede pedir fusionarlo (`gh pr merge --squash --delete-branch`).
