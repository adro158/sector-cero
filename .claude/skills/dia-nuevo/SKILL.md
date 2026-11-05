---
name: dia-nuevo
description: Ponerse al día al empezar una sesión de Sector Cero (main, PRs, issues, bitácora), validar y dar el informe de arranque. Úsalo cuando Adam o Alan digan «es un día nuevo», «empezamos», «estoy en clase» o «estoy en casa».
---

# Empezar una sesión

1. **Nada a medias**: `git status`. Si hay cambios sin commitear, avisar antes
   de seguir (pueden ser de la sesión anterior en este ordenador).
2. **Ponerse al día**:
   - `git fetch --prune`
   - `git switch main` y `git pull --ff-only`
   - las ramas propias abiertas (`git branch -vv`): si hay una a medias, ver
     su PR (`gh pr view <rama>`) y si `main` ha avanzado, traerlo
     (`git switch <rama>` y `git merge main`)
3. **Qué hay en marcha**: `gh pr list` (los PR del otro, que quizá toca
   revisar) y `gh issue list` (las tareas, sobre todo las asignadas a esta
   persona).
4. **Leer**: las últimas entradas de `documentacio/bitacora/`,
   `documentacio/requisitos_y_estado.md` y `documentacio/equipo/reparto.md`.
5. **Validar `main`** con `/validar`. Si algo está roto, es lo primero que hay
   que arreglar (o avisar a su dueño con una issue).
6. **Informe de arranque**, corto:
   - qué ha entrado en `main` desde la última vez (y de quién)
   - los PR que esperan revisión
   - las issues de esta persona
   - qué falta, por prioridad, y el siguiente paso
   - cualquier discrepancia entre la bitácora, el estado y Git
7. Antes de tocar código, **crear la rama de la tarea** desde `main`
   actualizada: `git switch -c <persona>/<tema>`.

Si la ficha de la persona dice que está en una máquina con GPU de verdad
(«estoy en casa»), además: capturas con ventana de lo cambiado, el simulador y
`medir_rendimiento.gd`, y lo que haya que jugar a mano, como una lista corta.
