# Créditos y procedencia de los assets — Sector Cero

El enunciado pide indicar la procedencia de los assets externos y respetar sus
licencias. Este fichero recoge **todo** lo que usa el juego, sea propio o no.

## Resumen

| Asset | Procedencia | Licencia |
|---|---|---|
| Código (GDScript) | Propio (Adam y Alan), escrito con ayuda de Claude | Del proyecto |
| Shaders (suelo, horda, CRT) | Propios | Del proyecto |
| Sprites de la horda, del élite y de las mejoras | Propios, generados por código | Del proyecto |
| Sprites del jugador (3 personajes) y del jefe | Hechos con IA (Gemini para la idea, Claude para las hojas de sprites) a partir de un ejemplo del profesor | Ver más abajo |
| Música y efectos de sonido | Propios, sintetizados por código | Del proyecto |
| Tipografía | Fuente monoespaciada del sistema (Consolas, Cascadia Mono, DejaVu Sans Mono o Liberation Mono) | No se distribuye con el juego |
| Motor | Godot Engine 4.7.2 | MIT |

## Detalle

### Código

Todo el código de `projecte/` es propio. Se ha escrito con la ayuda de Claude
(Anthropic) como asistente de programación. El uso de la IA está detallado en
la documentación técnica y, sesión a sesión, en la bitácora.

### Gráficos generados por código

`projecte/herramientas/generar_sprites.gd` dibuja píxel a píxel, con formas
simples (círculos, rectángulos y líneas) y un contorno de neón calculado a
partir de la silueta:

- Los tres tipos de la horda: bit corrupto, paquete perdido y proceso colgado
  (`recursos/enemigos/sprites/`).
- El élite Rootkit (`recursos/enemigos/sprites/rootkit.png`).
- Los iconos de las mejoras y de las herramientas (`recursos/mejoras/iconos/`).

El suelo de placa base, la rejilla, el glitch de la horda y el filtro CRT no
son imágenes: son shaders propios (`escenas/arena/suelo.gdshader`,
`medios/shaders/`).

### Sprites hechos con IA

Las hojas de animación de los tres personajes jugables (espadachín, mago y
segador) y la del jefe final (`escenas/jugabilidad/jugador/*.png` y
`escenas/jugabilidad/enemigos/jefe_8_direcciones.png`) se hicieron así:

1. **Punto de partida:** unos sprites de nigromantes que el profesor compartió
   en clase como ejemplo, creados con Claude.
2. **Idea:** Adam generó con **Gemini** una ilustración de algo parecido, pero
   con la temática del juego.
3. **Hojas de sprites:** **Claude** (Anthropic) creó a partir de ahí las cuatro
   hojas de ocho direcciones: los tres personajes y el jefe.
4. **Ajuste:** se adaptaron a la paleta del ordenador con scripts propios de
   Godot (quitar el fondo y recolorear; bitácora, sesión 4).

Se consideran provisionales: si hubiera tiempo, se sustituirían por pixel art
propio.

### Audio sintetizado

`projecte/herramientas/generar_audio.gd` genera todos los sonidos sumando ondas
simples (cuadrada, triángulo, sierra, seno y ruido), como los chips de sonido
de las consolas antiguas: 17 efectos y 3 músicas en bucle (menú, partida y
jefe). Las melodías y progresiones de acordes son propias. Los ficheros
resultantes están en `projecte/medios/audio/`.

### Tipografía

No se incluye ningún fichero de fuente. El juego pide al sistema una fuente
monoespaciada por orden de preferencia: Consolas (Windows), Cascadia Mono,
DejaVu Sans Mono o Liberation Mono (Linux). Si no encuentra ninguna, usa la
monoespaciada por defecto del sistema.

### Motor

[Godot Engine](https://godotengine.org) 4.7.2, con licencia MIT. El ejecutable
exportado incluye el motor.

### Recursos de terceros

El juego no usa ningún asset descargado de terceros: ni sprites, ni sonidos, ni
plugins, ni librerías. El único material ajeno es el ejemplo de sprites del
profesor, que sirvió de referencia y no está incluido en el juego.
