---
name: validar
description: Comprobar en headless que Sector Cero importa, arranca y juega sin errores. Úsalo antes de cada commit, al empezar la sesión y siempre que se diga «valida» o «comprueba que funciona».
---

# Validar el proyecto

Godot 4.7.2, con la ruta de la ficha de la persona. En PowerShell, los
argumentos con comas van entre comillas.

1. `--headless --path projecte --import`: no debe salir ningún `ERROR`,
   `Parse Error` ni `SCRIPT ERROR`.
2. `--headless --path projecte --quit-after 120`: solo se acepta el aviso
   conocido al salir (`resources still in use` / `ObjectDB instances were
   leaked`, del audio). Cualquier otro error, se investiga.
3. Una partida del simulador desde el minuto 10 y otra desde el 15:
   `--headless --fixed-fps 60 --path projecte --script res://herramientas/simular_partidas.gd -- partidas=1 minuto=15`.
   Sin `SCRIPT ERROR`. Si el cambio no toca el equilibrio, el resultado tiene
   que ser **el mismo que antes** (las semillas son fijas): el 05/11 eran
   «DERROTA tiempo=600s nivel=13 eliminados=22» (minuto 10) y «VICTORIA
   tiempo=1055s nivel=16 eliminados=428» (minuto 15). Si cambia sin querer,
   algo del cambio afecta a la partida.
4. **Clases globales**: contar `"class":` en
   `projecte/.godot/global_script_class_cache.cfg` (16 el 05/11). Si sube, hay
   que subir `EJECUTABLE_MINIMO` o cargar el script con `preload` sin
   `class_name`.
5. Si el cambio toca un shader o algo que solo se ve, una captura con ventana
   (un script temporal `extends SceneTree` fuera del repo que guarde el
   viewport).

Lo mismo lo hace la Action `comprobar.yml` en cada PR, pero en Linux: validar
antes en local ahorra esperas.
