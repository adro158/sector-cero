# Créditos y procedencia de los assets — Sector Cero

El enunciado pide indicar la procedencia de los assets externos y respetar sus
licencias. Este fichero recoge **todo** lo que usa el juego, sea propio o no.

## Resumen

| Asset | Procedencia | Licencia |
|---|---|---|
| Código (GDScript) | Propio (Adam y Alan), escrito con ayuda de Claude | Del proyecto |
| Shaders (suelo, horda, CRT) | Propios, escritos con ayuda de Claude | Del proyecto |
| Sprites de la horda (5 tipos) y del élite | Hechos con IA (Claude) | Ver más abajo |
| Texturas del suelo de placa base | Hechas con IA (Claude) | Ver más abajo |
| Iconos de las mejoras | 8 propios, generados por código; 3 hechos con IA (Claude) | Del proyecto / ver más abajo |
| Sprites del fragmento de datos y del proyectil del Ping | Hechos con IA (Claude) | Ver más abajo |
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
partir de la silueta, los iconos de las cinco primeras mejoras y de las tres
herramientas (`recursos/mejoras/iconos/`).

Hasta el 02/10/2026 también dibujaba los sprites de la horda y del élite; se
sustituyeron por los redibujados con IA (siguiente apartado) y ese código se
quitó del script para que no los machaque.

El glitch de la horda, el parpadeo del troyano y el filtro CRT no son imágenes:
son shaders (`medios/shaders/`). El suelo combina un shader
(`escenas/arena/suelo.gdshader`) con las texturas del apartado siguiente.

### Sprites, iconos y suelo hechos con Claude

Adam encargó a **Claude** (Anthropic), en una conversación aparte, el arte
nuevo de la sesión del 02/10/2026. Claude lo dibujó con scripts de Python
(píxel a píxel, con NumPy y Pillow) y Adam lo integró en el proyecto. Los
scripts no forman parte del repositorio.

- **Enemigos redibujados** (`recursos/enemigos/sprites/`): bit corrupto,
  paquete perdido, proceso colgado y el élite Rootkit, con el mismo nombre,
  tamaño y color principal que los antiguos, pero con sombreado, contorno y
  más expresión.
- **Enemigos nuevos**: el ransomware (candado rojo con cadenas, 44x44) y el
  troyano (caballo de ajedrez verde con trampilla, 32x32).
- **Iconos de tres mejoras** (`recursos/mejoras/iconos/`): Actualizar firmas
  (escudo con check), Cambio en caliente (flechas) y Caché ampliada (imán).
- **Suelo de placa base** (`medios/texturas/`): `suelo_placa.png`, un atlas de
  12 baldosas de 256x256 que encajan sin costuras (pistas, vías, chips, CPU,
  GPU, memorias, ranuras, disipadores y ventiladores);
  `suelo_placa_mascara.png`, que marca por dónde corren los pulsos de datos, y
  `suelo_placa_efectos.png`, que marca los LEDs, las aspas de los ventiladores
  y el brillo de los chips. Con ellas vinieron el shader del suelo y el script
  de la arena que lo anima.
- **Experiencia y Ping** (`medios/sprites/`, el mismo día y de la misma
  forma): `fragmento_datos.png` (12x12), un cristal de datos en grises que el
  juego tiñe según lo que vale, y `proyectil_ping.png` (24x12), un rayo de
  energía con estela que el juego gira hacia donde va.

### Sprites de los personajes y del jefe

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
profesor, que sirvió de referencia y no está incluido en el juego. Lo hecho con
IA está señalado en los apartados anteriores.
