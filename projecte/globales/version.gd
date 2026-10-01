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
## clases con class_name. Si una versión cambia algo de eso, se sube este número
## a esa versión y los ejecutables más antiguos pedirán bajar el juego entero.
const EJECUTABLE_MINIMO := "0.2"
