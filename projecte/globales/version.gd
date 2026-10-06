class_name Version
extends RefCounted

## La versión del contenido del juego. En el código es "desarrollo"; la GitHub
## Action que publica las releases la sustituye por la de la etiqueta (v0.3 da
## "0.3") justo antes de exportar.
const ACTUAL := "desarrollo"

## La versión más antigua del ejecutable que puede usar este contenido. Las
## actualizaciones solo cambian el .pck (escenas, scripts, sonidos...). Lo que
## Godot lee al arrancar, antes de cargar la actualización, se queda como venía
## en el ejecutable: project.godot (autoloads, controles, ventana) y la lista de
## clases con class_name, y también actualizador.gd, que es quien carga la
## actualización y por eso ya está en marcha antes. Si una versión cambia algo
## de eso, se sube este número a esa versión y los ejecutables más antiguos
## pedirán el juego entero, que instalador_juego.gd descarga y pone solo.
##
## Vuelve a ser 0.2 desde la v0.7: la v0.6 lo subió a 0.6 por un cambio en
## actualizador.gd, y así los ejecutables v0.5 solo podían abrir la página de
## GitHub. El contenido de ahora funciona con cualquier ejecutable desde la
## v0.2 (solo le faltaría el aviso automático, que crea el actualizador nuevo).
const EJECUTABLE_MINIMO := "0.2"
