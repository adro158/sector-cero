---
name: publicar
description: Publicar una versión nueva de Sector Cero (novedades, etiqueta y comprobar la release). Úsalo solo cuando quien publica (Adam, según su ficha) diga «publica la vX».
---

# Publicar una versión

Solo lo hace quien publica según `documentacio/equipo/` (Adam). Si lo pide
otra persona, decírselo y no seguir.

1. **Desde `main` al día** (`git switch main`, `git pull --ff-only`) y sin PR
   a medio fusionar que deba entrar.
2. `/validar`.
3. **¿Hace falta subir `EJECUTABLE_MINIMO`?**:
   - `git diff <última etiqueta> -- projecte/project.godot`
   - y el número de clases globales

   Ver «Versiones» en `CLAUDE.md`.
4. **Novedades**: `documentacio/novedades/<versión>.txt`, en el estilo de las
   anteriores (frases cortas, para el jugador). Entra en `main` con un PR
   pequeño, como todo.
5. **Etiqueta** desde `main`: `git tag <versión>` y
   `git push origin <versión>`.
6. **Comprobar la Action**: `gh run list --limit 1` y `gh run watch <id>` (en
   segundo plano). Después, `gh release view <versión>` con sus 7 ficheros:
   - los dos instaladores
   - `lanzador_windows.pck` y `lanzador_linux.pck`
   - `sector_cero_windows.pck` y `sector_cero_linux.pck`
   - `version.json`
7. Apuntarlo en la bitácora de la sesión y en `requisitos_y_estado.md`.
