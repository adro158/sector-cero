# Mejoras propuestas para Sector Cero

Revisión del 22/10/2026 (sesión 18), pedida por Adam: «qué mejoras le podría
hacer al juego», sobre todo lo visual que aún está hecho por código y
quedaría mejor con assets. La hicieron cuatro agentes de Claude en paralelo,
uno por área, mirando el código de la v1.8:
- lo visual de la partida
- la interfaz y el lanzador
- el sonido y la sensación de juego
- la jugabilidad

Cada propuesta cita cómo está ahora (fichero y función). Claude comprobó a
mano en el código los fallos del apartado A.

**Nada de esto está decidido:** es una lista para que Adam elija. No se
incluye lo que ya estaba pendiente (el cooperativo, el cono del Espadachín y
las animaciones de ataque del punto 15 de `requisitos_y_estado.md`); si una
propuesta ya estaba apuntada en otro sitio, lo dice. Las referencias entre
paréntesis son a las secciones de abajo: «visual 2» es la propuesta 2 de «Lo
visual de la partida».

## Resumen por prioridad

### A. Fallos que conviene arreglar ya (pequeños y sin assets)

- **Textos de las reglas que ya no cuadran** (jugabilidad 1):
  - el robo de vida dice «hasta 3», pero el tope es 1,5 desde el 22/10
  - las evoluciones dicen que el malware no les tiene resistencia, pero se
    adapta a ellas como a todas
  - el Ping y su evolución parecen saltar lo mismo
  - a NÚCLEO CERO le falta el escudo cada 35 s
  - la ficha de un ancla enseña una resistencia que no tiene
  - «+25 de integridad» no dice que es para los tres personajes
- **El ranking se pierde sin avisar** si en la pantalla final se pulsa
  REINTENTAR o MENÚ sin GUARDAR (jugabilidad 3).
- **Se ofrece la evolución de un personaje caído:** ocupa una tarjeta en
  cada subida y no sirve de nada (jugabilidad 5).
- **El ranking y los récords no miran la dificultad:** una victoria en fácil
  va delante de una en difícil, y «MEJOR PARTIDA» junta datos de partidas
  distintas (jugabilidad 7).
- **La partida no se pausa al cambiar de ventana** (por ejemplo, en la
  defensa, para enseñar el código) (jugabilidad 4).
- **Opciones que ya no hacen nada:** «Avisar de versiones nuevas» desde el
  lanzador, y el botón VERSIONES en la web (interfaz 10).
- **El aviso de la embestida del jefe del minuto 10** es solo un tinte rojo.
  Se puede dibujar la franja con flechas que ya usa NÚCLEO CERO (visual 1).

### B. Que se vea el elemento diferencial (lo propusieron tres áreas)

La resistencia adaptativa es lo que más puntos da ante el tribunal, y hoy
casi no se ve al jugar: solo en el panel técnico (F3).
- Indicador en el HUD (interfaz 1).
- Aviso cuando el malware se adapta (jugabilidad 2).
- Sonido al adaptarse (sonido 5).

### C. Sensación de juego, sin assets

- **Tiempo de golpe** (hit stop) en los momentos fuertes (sonido 1).
- **Una sola sacudida de cámara**, según el golpe y con opción para quitarla
  (sonido 6; jugabilidad 12, accesibilidad).
- **Música amortiguada** mientras se elige mejora o se está en pausa
  (sonido 9).
- **Números de daño** con la letra del juego, contorno y más pegada
  (visual 4, sonido 12).
- **Los jefes no se quedan casi blancos** al recibir golpes (visual 9,
  sonido 15; ya apuntado en la bitácora, sesión 18).

### D. Lo visual hecho por código que quedaría mejor con assets

- **En la partida:**
  - partículas con textura en vez de cuadrados (visual 5)
  - animación al caer un personaje y al perder (visual 2)
  - golpe recibido y protección visibles (visual 3)
  - muerte propia de los élites (visual 6)
  - efecto al evolucionar (visual 7)
  - invocación del jefe con sprites (visual 8)
  - barras de vida con marco (visual 10)
  - Ping animado y distinto con la evolución (visual 11)
  - fragmentos con brillo (visual 15)
  - mira de la ulti del Mago (visual 14)
- **En la interfaz:**
  - fuente pixel art propia (interfaz 2)
  - paneles y botones de pixel art en lugar de los hechos por código
    (interfaz 4)
  - barra del equipo con retratos (interfaz 3)
  - HUD de arriba (interfaz 8)
  - teclas y botones dibujados según se juegue con teclado, mando o
    pantalla táctil (interfaz 12)
  - lanzador más visual (interfaz 14)
  - ranking con retratos y medallas (interfaz 15)
- **Más grande:**
  - hoja definitiva del jefe del minuto 10 con poses de ataque (visual 12)
  - animación de reposo de los personajes (visual 13)

### E. Sonido y música (se pueden seguir sintetizando por código)

- Sonidos del escudo de NÚCLEO CERO: golpe bloqueado, ancla rota y escudo
  roto (sonido 2).
- Sonido propio para las ultis y las herramientas evolucionadas (sonido 3).
- Música propia para la fase 2 y NÚCLEO CERO (sonido 4), o por capas que
  crece con la partida (sonido 8).
- Avisos sonoros de los ataques de los jefes (sonido 7).
- Aviso de poca vida (sonido 10).
- Sonidos al recoger cosas (sonido 11) y al moverse por los menús
  (sonido 13).
- Cámara lenta al caer (sonido 14).

### F. Experiencia de juego y contenido

- **Consejos durante la primera partida** (jugabilidad 10).
- **Resumen de la partida en la pantalla final:** daño por herramienta,
  dónde acabó, si se usó F1 y con qué se jugó (jugabilidad 11, interfaz 5).
- **Menú principal** con menos texto y los personajes a la vista
  (interfaz 6).
- **Pausa:** confirmar antes de abandonar y botón de REGLAS (interfaz 7,
  jugabilidad 13).
- **Subida de nivel y ruleta** con entrada animada y un instante sin poder
  elegir, para no elegir sin querer (interfaz 9).
- **Avisos del HUD** en cola (interfaz 11).
- **Reglas** con los textos partidos y dibujos (interfaz 13).
- **Explicar el escudo de NÚCLEO CERO** al jugador (jugabilidad 6).
- **Mando completo y vibración** (jugabilidad 8 y 9).
- **Accesibilidad:** texto más grande (jugabilidad 12).
- **Un enemigo propio de la fase 2**, el Popup de la lista de assets de Alan
  (jugabilidad 14).

**Recomendación de Claude:** primero A y B, que son pequeños, sin assets, y
se notan en la defensa. Después C. Lo de D y E, por lotes de assets como los
de `prompt_assets.md`.

---

# Detalle de cada propuesta

## Lo visual de la partida que aún se dibuja por código

### 1. Aviso de la embestida de Kernel Panic con una línea en el suelo

Impacto **alto** · esfuerzo **pequeño** · assets: **no**

- **Cómo está ahora:** La embestida de Kernel Panic solo avisa tiñendo el sprite de rojo: `_cambiar_estado` pone `_sprite.modulate = color_aviso` (escenas/jugabilidad/enemigos/jefe.gd:304) y en `Estado.AVISO` (jefe.gd:214) solo se gira hacia el jugador. No se dibuja hacia dónde va a salir ni hasta dónde llega (480 px/s × 0,7 s ≈ 336 px). El troyano tampoco: solo parpadea en rojo en el shader (`INSTANCE_CUSTOM.g` de horda.gdshader). NÚCLEO CERO, en cambio, avisa su rayo con flechas que avanzan sobre una franja (`aviso_linea`, dibujo_jefe_final.gd:54-60).
- **Propuesta:** Durante el AVISO, dibujar en el `_draw` del jefe (jefe.gd:323) la misma franja con flechas de NÚCLEO CERO: `DibujoJefeFinal.aviso_linea(self, Vector2.ZERO, _direccion, velocidad_embestida * duracion_embestida, (radio + 16) * 2, _tiempo_estado)`. Es la función que ya existe, con preload y sin class_name. Se ve hacia dónde y hasta dónde va a embestir, y queda igual que el aviso del jefe final. Si se hace la embestida triple, cada embestida usaría este mismo aviso. Para el troyano se podría hacer igual desde el `_draw` del gestor (como la barra del ransomware, gestor_enemigos.gd:263), pero ahí puede haber muchos a la vez: mejor solo en el jefe.
- **Ya apuntado:** El aviso en el suelo no. Está relacionado con la embestida triple, que sigue pendiente (requisitos_y_estado.md, punto 3.4: «cada una con su aviso rojo corto»).

### 2. Animación al caer un personaje y al perder la partida

Impacto **alto** · esfuerzo **medio** · assets: **sí**

- **Cómo está ahora:** Cuando un personaje se queda sin vida no hay ninguna animación. `_al_caer` (escenas/jugabilidad/jugador/cambio_personaje.gd:169-180) pausa el árbol en ese mismo fotograma y emite `personaje_caido`. Si caen los tres, `equipo_derrotado` llama a `_terminar_partida(false)` (raiz_juego.gd:29 y 90-97), que también pausa al momento y saca la pantalla final. Al jefe y a NÚCLEO CERO sí se les deja morir con su animación antes de seguir (`_al_acabar_de_morir`, jefe.gd:343; `Estado.MURIENDO`, jefe_final.gd:285).
- **Propuesta:** Hacer lo mismo con el personaje: al caer, el sprite se deshace con glitch durante unos 0,6-0,8 s y después llega la pausa (el panel para elegir quién sigue o la pantalla final). Mientras dura, el jugador no se mueve y, como la vida ya es 0, `Salud.recibir_dano` no hace nada (salud.gd:89). Se puede dibujar desde `efectos_jugador.gd`, que ya pinta tiras de fotogramas encima del personaje, y bajar la opacidad del sprite con un tween. Ojo: retrasa la pausa, así que luego hay que pasar el simulador para comprobar que no cambia nada.
- **Assets:** Una tira en grises para teñirla con el color del personaje: el cuerpo deshaciéndose en píxeles y líneas de glitch. 96x96, unos 8 fotogramas a 0,08 s, centrada en el sprite (0, -22). Opcional, una variante más larga para la derrota final (10-12 fotogramas).

### 3. Golpe recibido y protección visibles en el jugador

Impacto **medio** · esfuerzo **pequeño** · assets: **sí**

- **Cómo está ahora:** Al recibir daño, `_al_recibir_dano` (escenas/jugabilidad/jugador/controlador_jugador.gd:34-46) tiñe el sprite de rojo con `modulate`, da un tirón de cámara y `pool_particulas.gd:91-92` suelta 10 cuadrados rojos. Hay dos protecciones que no se ven: los 0,5 s de invulnerabilidad después de cada golpe (`invulnerabilidad` en salud.gd) y los 2 s al entrar tras una caída (`_salud.proteger(proteccion_al_entrar)`, cambio_personaje.gd:188).
- **Propuesta:** Al recibir un golpe, sacar un destello de impacto con grietas o glitch encima del personaje, en `efectos_jugador.gd`, como el de curarse. Durante la invulnerabilidad, hacer parpadear el sprite (sin assets, con `modulate.a`; haría falta que `Salud` diga si está protegido). Durante la protección larga, dibujar una burbuja o un escudo del color del personaje. Así se entiende por qué algunos golpes no quitan vida.
- **Assets:** Impacto: 64x64, 4 fotogramas a 0,05 s, en grises (se tiñe de rojo), encima del personaje. Escudo de protección: 80x80, 4 fotogramas en bucle a 0,1 s, en grises para teñirlo con el color del personaje, tramado para que se vea el personaje a través.

### 4. Números de daño y textos de la partida con la letra del juego y contorno

Impacto **medio** · esfuerzo **pequeño** · assets: **sí**

- **Cómo está ahora:** Los números de daño se dibujan con `draw_string(ThemeDB.fallback_font, ...)` a 15 px y sin contorno (escenas/jugabilidad/efectos/pool_numeros_flotantes.gd:30 y 79-87). Es la letra por defecto de Godot, no la monoespaciada del juego (`SystemFont` en escenas/interfaz/estilo_interfaz.gd:24). Lo mismo pasa con los nombres de los afijos encima de cada élite (enemigo_elite.gd:214), la «R» de la ulti (barra_vida.gd:51) y el «CLICK» de la mira del Mago (dibujo_ultis.gd:96). Sobre el suelo de neón y la horda, sin contorno, cuestan de leer.
- **Propuesta:** Sin assets: usar la fuente del tema (`EstiloInterfaz.tema().default_font`) y dibujar primero el contorno con `draw_string_outline` (comprobar que está en la API de 4.7.2) y después el texto. Con assets: una tira de dígitos en pixel art con contorno, dibujada con `draw_texture_rect_region` (una sola textura, así que sigue siendo una llamada de dibujado), que encaja con el resto del arte. Además, encima de los élites ya están los iconos de los afijos (lote 6), así que el nombre escrito se podría quitar o dejar más pequeño.
- **Assets:** Opcional: tira de dígitos 0-9 (y «+») de unos 8x12 px por carácter, con contorno oscuro de 1 px, en blanco para teñirla (amarillo normal, rojo si se resiste, verde al curar).

### 5. Partículas con textura en vez de cuadrados lisos

Impacto **medio** · esfuerzo **pequeño** · assets: **sí**

- **Cómo está ahora:** `pool_particulas.gd` dibuja todas las partículas como un `QuadMesh` de 4x4 sin textura (`_preparar_multimesh`, escenas/jugabilidad/efectos/pool_particulas.gd:49-60). Salen cuadrados de color liso en la muerte de la horda (3), de los élites (50) y del jefe (160), al explotar el rootkit (90), al subir de nivel (40), al evolucionar (80) y al recibir daño (10) (líneas 43-46 y 76-92). Es lo que más se ve hecho por código.
- **Propuesta:** Ponerle una textura pequeña a la `MultiMeshInstance2D` (como `pool_gemas.gd:70`, con escala vertical -1 en la transformación, línea 123) y seguir tiñéndola con el color de cada instancia. Con una chispa o un bit («0»/«1») de pixel art queda en el estilo del ordenador infectado y sigue siendo una sola llamada de dibujado.
- **Assets:** Una chispa o un bit de 6x6 u 8x8 px en grises, con el centro más claro. Un solo fotograma: todas las partículas comparten la textura del MultiMesh.

### 6. Muerte propia de los élites

Impacto **medio** · esfuerzo **pequeño** · assets: **sí**

- **Cómo está ahora:** Cuando muere un élite que no es Explosivo, simplemente desaparece: `visible = false` (escenas/jugabilidad/enemigos/enemigo_elite.gd:189) y `pool_particulas.gd:83` suelta 50 cuadrados de su color. La animación de muerte de la horda no le llega, porque `muertes_horda.gd:31-32` solo coge los tipos de los gestores. Mientras vive, el Explosivo se marca con un `draw_arc` fino por código (dibujo_elite.gd:49-51), porque los otros afijos tienen su efecto con sprites (lote 5) y este solo al morir.
- **Propuesta:** Opción barata, sin assets: en `muertes_horda.gd` añadir el tipo «elite» con su color y la escala 48/24, para que el rootkit se deshaga con la misma animación al doble de tamaño. Opción buena: una animación propia en dorado, que se agriete y se deshaga en datos, coherente con la sobrecarga del Explosivo. De paso, cambiar el anillo del Explosivo en vida por un efecto con sprites (chispas o una mecha encendida), como los otros afijos.
- **Assets:** Muerte del rootkit: 96x96, 8 fotogramas a 0,06 s, dorada, centrada. Explosivo en vida: 64x64, 4 fotogramas en bucle a 0,12 s, en grises para teñirlo de naranja, detrás del rootkit (va en el diccionario AFIJOS de dibujo_elite.gd:23).

### 7. Efecto propio al evolucionar una herramienta

Impacto **medio** · esfuerzo **pequeño** · assets: **sí**

- **Cómo está ahora:** Al evolucionar solo salen 80 cuadrados, siempre verdes (`EstiloInterfaz.VICTORIA`), desde el personaje activo (escenas/jugabilidad/efectos/pool_particulas.gd:45), aunque la herramienta que evoluciona sea de un personaje del banquillo (`evolucionar` emite para cualquiera, cambio_personaje.gd:159-166). `efectos_jugador.gd` tiene efectos para subir de nivel, cambiar y curarse, pero ninguno para evolucionar (y el del cambio se salta adrede la evolución, línea 35-37). Es el momento más importante de la progresión.
- **Propuesta:** Añadir en `efectos_jugador.gd` un efecto de evolución, igual que `SUBIR_NIVEL` y con la lista `_efectos` que ya existe, teñido del color del personaje. Que solo salga si el que evoluciona es el activo (si no, ya avisa el HUD). Se puede quitar el estallido verde de pool_particulas o dejarlo del color del personaje.
- **Assets:** 128x128, unos 10 fotogramas a 0,07 s, en grises para teñirlo: un anillo de luz que sube, el arma que destella y unos glifos de datos. Encima del personaje y tramado, como subir_nivel.png.

### 8. Invocación de Kernel Panic con sprites

Impacto **medio** · esfuerzo **pequeño** · assets: **sí**

- **Cómo está ahora:** Cuando Kernel Panic invoca su anillo de horda se dibuja un `draw_arc` morado de 4 px que crece (escenas/jugabilidad/enemigos/jefe.gd:328-330) y el sprite late en morado con `modulate` (jefe.gd:224-227). La ráfaga avisa igual, con el mismo latido (jefe.gd:238-241). Las invocaciones de NÚCLEO CERO, en cambio, salen de portales con sprites (`portal`, dibujo_jefe_final.gd:65-73).
- **Propuesta:** Dibujar un círculo de invocación con sprites que se cierre hasta `radio_invocacion` (140 px), o abrir un portal pequeño en cada punto donde va a salir un enemigo. Se puede reutilizar `jefe_final_portal.png` (morado con los tres colores) a escala ~0,4, pero entonces se parecería a NÚCLEO CERO. Así se ve antes dónde saldrá la horda.
- **Assets:** Círculo de invocación: 320x320, 8 fotogramas a 0,125 s (lo que dura el aviso de 1 s), morado #BF4DFF, con runas o datos que se cierran, debajo del jefe. Alternativa sin assets nuevos: el portal del jefe final escalado.

### 9. Que los jefes no se queden casi blancos al recibir golpes

Impacto **medio** · esfuerzo **pequeño** · assets: **no**

- **Cómo está ahora:** `sprite_destello.gd` pone el sprite blanco 0,1 s en cada golpe (`DURACION`, línea 12; `destellar`, línea 25). Kernel Panic lo llama en cada `danar_en_area` (jefe.gd:151) y NÚCLEO CERO también (jefe_final.gd:130). Con el Firewall pegando cada 0,5-0,6 s y los rebotes del Ping, en las capturas Kernel Panic sale casi siempre blanco y se pierde su dibujo.
- **Propuesta:** En los jefes, limitar el destello: que vuelva a destellar como mucho cada ~0,25 s (como el 0 rojo de las anclas, que sale como mucho cada 0,3 s) o que destelle a media intensidad. Es un cambio en `sprite_destello.gd`, con un parámetro, sin tocar a los élites.
- **Ya apuntado:** bitacora.md, sesión 18, «Problemas encontrados»: «El jefe del minuto 10 sale casi blanco», anotado para mirarlo jugando.

### 10. Barras de vida con marco de sprite y aviso de ulti que valga para el mando

Impacto **medio** · esfuerzo **pequeño** · assets: **sí**

- **Cómo está ahora:** La barra del personaje son `draw_rect` con un color que va de rojo a verde, una barra fina amarilla para la ulti y una «R» escrita (escenas/jugabilidad/jugador/barra_vida.gd:40-51). La «R» sale también con mando, donde la ulti va con B, y en el móvil. Las barras del ransomware, de los élites y de las anclas también son `draw_rect` (barra_vida_enemigo.gd:13-18, usada en gestor_enemigos.gd:268, enemigo_elite.gd:212 y ancla_escudo.gd:134). Las de los dos jefes sí tienen marco y relleno de sprite (escenas/interfaz/barra_jefe.gd:44-46).
- **Propuesta:** Hacer las barras pequeñas como las de los jefes: un marco de sprite y encima el relleno recortado según la vida (`draw_texture_rect_region`, como barra_jefe.gd:46). El relleno en grises para teñirlo con el color de cada uno. En la del personaje, cambiar la «R» por un icono de ulti lista que valga para teclado, mando y táctil. Además, el comentario de barra_vida_enemigo.gd:3 dice que la usa el jefe, pero el jefe ya tiene la suya arriba: hay que actualizarlo.
- **Assets:** Barra de enemigo: marco de 48x9 y relleno de 44x5 en grises (o un nine-patch de unos 12x9 para estirarlo a 70 px en el élite). Barra del personaje: marco de 44x12 con dos huecos (vida y ulti) e icono de ulti lista de 8x8, 2 fotogramas para que parpadee.

### 11. Proyectil del Ping animado y distinto con la evolución

Impacto **medio** · esfuerzo **medio** · assets: **sí**

- **Cómo está ahora:** Todos los proyectiles usan una sola textura fija, `proyectil_ping.png` de 24x12 (export `textura` en escenas/jugabilidad/armas/pool_proyectiles.gd:17 y 70, asignada en raiz_juego.tscn:116). No tiene animación ni estela, y el Ping de inundación dispara el mismo dibujo que el Ping: en `DatosArma` los dibujos propios solo existen para las armas de área (`efecto` y `anillo`, recursos/armas/datos_arma.gd:27-37). El Firewall perimetral y el Análisis heurístico sí cambian de efecto al evolucionar; el Ping no.
- **Propuesta:** Añadir a `DatosArma`, en «Solo proyectiles», un export `proyectil` (tira de fotogramas), igual que se hizo con `efecto`. Que `pool_proyectiles` cambie la textura del MultiMesh al cambiar de arma y elija el fotograma con un shader pequeño a partir del tiempo, como la horda. El Ping de inundación tendría su propio dibujo, más grande o de doble rayo.
- **Assets:** Ping: 24x12, 4 fotogramas a 0,06 s, morado #BF73FF, apuntando a la derecha (el fotograma 0 es el actual). Ping de inundación: el mismo tamaño o 32x14, 4 fotogramas, más intenso, con estela.

### 12. Kernel Panic: hoja definitiva con poses de ataque

Impacto **alto** · esfuerzo **grande** · assets: **sí**

- **Cómo está ahora:** La hoja de Kernel Panic (escenas/jugabilidad/enemigos/jefe_8_direcciones.png, 1536x1152: 12 fotogramas de 128x144 × 8 direcciones) solo tiene el ciclo de andar. Al avisar, invocar, disparar la ráfaga o pisar se queda quieto en un fotograma (`_animar` solo avanza al perseguir y al embestir, jefe.gd:309-317), y los ataques se distinguen solo por el tinte rojo o morado (`modulate`, jefe.gd:227, 241 y 304). creditos.md dice que esta hoja es provisional.
- **Propuesta:** Rehacer la hoja con su pixel art definitivo y añadir poses de ataque: alzar el bastón para invocar o disparar la ráfaga, agacharse antes de embestir y dar un pisotón. `_animar` elegiría la tira según `_estado`. Es lo que más se notaría en el minuto 10, el momento fuerte de la demo.
- **Assets:** Hoja de ataque de 128x144 por fotograma, 8 direcciones × 4-6 fotogramas por pose (lanzar y pisotón; la embestida puede reutilizar la de lanzar). Sería una hoja de unos 768x1152 por pose, con el mismo cuerpo, la misma paleta y la misma sombra que la de andar.
- **Ya apuntado:** requisitos_y_estado.md, punto 12 («Opcional: sustituir los sprites de IA por pixel art propio») y creditos.md (los personajes y el jefe «se consideran provisionales»). Las poses de ataque no están apuntadas.

### 13. Animación de reposo de los personajes

Impacto **medio** · esfuerzo **medio** · assets: **sí**

- **Cómo está ahora:** Cuando el jugador está quieto, el personaje se queda en el primer fotograma del ciclo de andar (`_animar`, escenas/jugabilidad/jugador/controlador_jugador.gd:89-92: «Quieto: primer fotograma»). Las hojas solo tienen andar (6x8 de 64x72), también las de evolución. Los élites sí tienen reposo desde el lote 5 (`fotograma_reposo`, dibujo_elite.gd:34).
- **Propuesta:** Añadir una tira de reposo por personaje (la capa que ondea, los ojos que brillan, el arma que late) y elegirla en `_animar` cuando `direccion == Vector2.ZERO`. Como con `hoja_evolucion`: un campo nuevo en `DatosPersonaje` y, en `cambio_personaje._aplicar` (línea 212), la hoja que toque. Sin class_name nuevo.
- **Assets:** Por personaje y por versión (normal y evolucionada, 6 hojas): 4 fotogramas × 8 direcciones de 64x72 (256x576), a unos 0,15 s por fotograma, con el cuerpo idéntico al de andar.
- **Ya apuntado:** El reposo no. El redibujado de los personajes en general sí: requisitos_y_estado.md, punto 12.

### 14. Mira de la ulti del Mago con sprites

Impacto **bajo** · esfuerzo **pequeño** · assets: **sí**

- **Cómo está ahora:** Mientras el Mago apunta la ulti con el ratón se dibuja una línea morada a trazos (`draw_dashed_line`), un círculo (`draw_circle`) y la palabra «CLICK» con la letra por defecto (`mira`, escenas/jugabilidad/jugador/dibujo_ultis.gd:90-96). El propio comentario dice «Sin sprite». Lo llama ultis.gd:203. El rayo en sí sí es de sprites.
- **Propuesta:** Dibujar la mira como el aviso del rayo de NÚCLEO CERO (tramos con flechas que avanzan, dibujo_jefe_final.gd:54-60) pero en morado, con una diana al final y un icono de ratón en vez de «CLICK».
- **Assets:** Tramo de la mira: 32x16, 4 fotogramas a 0,08 s, morado #BF73FF, que se repite a lo largo. Diana: 32x32, 2-4 fotogramas en bucle. Icono de click izquierdo: 16x16.

### 15. Fragmentos de datos con brillo y recogida visible

Impacto **bajo** · esfuerzo **medio** · assets: **sí**

- **Cómo está ahora:** Los fragmentos de experiencia son un sprite fijo de 12x12 teñido según lo que valen (escenas/jugabilidad/progresion/pool_gemas.gd:6 y 116-131). La única animación es el parpadeo de los últimos 3 s (línea 127). Al recogerlos desaparecen sin ningún efecto (`experiencia_ganada.emit` y `_eliminar`, líneas 94-96).
- **Propuesta:** Darles un brillo que recorra el cristal, con un shader pequeño que elija el fotograma con un desfase por instancia, como la horda. Sin assets, basta con un pulso de escala en la transformación de cada instancia. Al recogerlos, un destello pequeño: mejor uno solo que se reinicia en el personaje que uno por fragmento, porque se recogen decenas.
- **Assets:** fragmento_datos en tira: 12x12, 4 fotogramas en grises (el 0 es el actual), a 0,12 s. Opcional, destello de recogida: 24x24, 4 fotogramas.

## La interfaz y el lanzador

### 1. Que se vea la resistencia adaptativa en el HUD (el factor diferencial)

Impacto **alto** · esfuerzo **pequeño** · assets: **sí**

- **Cómo está ahora:** escenas/jugabilidad/enemigos/resistencia_malware.gd emite cada 20 s la señal local resistencia_cambiada (línea 12, emitida en _cambiar, línea 81), pero no la escucha nadie (grep: ningún connect). El jugador solo lo nota porque el anillo del arma se tiñe de rojo (aura_arma.gd, línea 104) y por los números de daño rojos, como dice la propia regla (panel_reglas.gd, COMO_SE_JUEGA, línea 38). El porcentaje solo sale en el panel del equipo, oculto hasta pulsar C (panel_equipo.gd, _escribir_ficha, líneas 152-153), y en la ficha del enemigo, que solo se abre haciendo click en uno (ficha_enemigo.gd, _texto_resistencia, 126-130).
- **Propuesta:** Un indicador pequeño junto al equipo: el icono de la herramienta activa con un medidor rojo de 0 a 50 %, y un aviso del HUD cuando sube («EL MALWARE SE ADAPTA AL FIREWALL: 30 %. ¡CAMBIA DE PERSONAJE!»). Para no saltarse la frontera, pasar resistencia_cambiada(arma, valor) al BusEventos (y a la lista de GEMINI.md) y emitirla desde _cambiar. Es lo que el tribunal tiene que ver para entender lo que diferencia al juego, y hoy casi no se ve.
- **Assets:** Icono de 16x16 de «firma del malware» o escudo, en grises para teñirlo. Marco del medidor (unos 64x12) y su relleno. Opcional: un latido de 4 fotogramas de 16x16 para cuando sube.

### 2. Fuente pixel art propia en lugar de la del sistema

Impacto **alto** · esfuerzo **medio** · assets: **sí**

- **Cómo está ahora:** EstiloInterfaz.tema() (escenas/interfaz/estilo_interfaz.gd, líneas 24-25) usa un SystemFont: Consolas, Cascadia Mono, DejaVu Sans Mono... Lo mismo hace el lanzador (lanzador/estilo.gd, tema(), líneas 16-17). Cada sistema enseña una letra distinta: panel_mejoras.gd (_crear_tarjeta, líneas 54-57) tuvo que agrandar las tarjetas a 260x320 porque «la fuente de Linux es más ancha». Además, muchos textos se pintan con ThemeDB.fallback_font, que es la fuente por defecto de Godot y no es monoespaciada: los números de daño (pool_numeros_flotantes.gd:30), el texto de los élites (enemigo_elite.gd:214), la «R» de la ulti (barra_vida.gd:51), el «CLICK» de la ulti del Mago (dibujo_ultis.gd:96) y los botones táctiles (control_tactil.gd:137). Hay dos fuentes mezcladas, y ninguna es pixel art. En la web no hay fuentes del sistema, así que seguramente sale la de Godot: hay que comprobarlo en la versión publicada.
- **Propuesta:** Dibujar una fuente monoespaciada de pixel art (con Python, como el resto de assets) e importarla con el importador «Font Data (Image Font)» de Godot, con escalado entero (fixed_size_scale_mode; comprobar la API en 4.7.2). Usarla en EstiloInterfaz.tema(), en Estilo.tema() del lanzador (copiando el fichero, porque es otro proyecto) y en vez de ThemeDB.fallback_font en los cinco sitios de arriba. Los tamaños de letra tendrían que pasar a múltiplos del tamaño base: hoy hay 11, 12, 13, 14, 15, 16, 18, 20, 26, 30, 32, 36, 40 y 44. Así la letra es la misma en Windows, Linux y web, y encaja con el resto del pixel art.
- **Assets:** Una hoja PNG con los caracteres en rejilla fija (por ejemplo, celdas de 8x12 px y 16 columnas): ASCII del 32 al 126 más ÁÉÍÓÚÜÑ áéíóúüñ ¡ ¿ · → « » × %, que son los que usan los textos (los «NIVEL 1 → 2», los «·» de los separadores, los «¡JEFE!»...). Opcional: una variante grande o gruesa para los títulos.
- **Ya apuntado:** documentacio/assets.md (de Alan), «Tipografía y shaders»: se pedía una monoespaciada «elegida, no dibujada», que es la del sistema. No hay nada pendiente sobre una fuente propia.

### 3. Barra del equipo con retratos, espera y carga de la ulti, en vez de una línea de texto

Impacto **alto** · esfuerzo **medio** · assets: **sí**

- **Cómo está ahora:** Abajo en el centro hay una sola Label (panel_equipo.gd, _escribir_linea, líneas 115-128) con «ESPADACHÍN · Firewall  [Q] Mago · Segador [E]  [R] ¡ULTI!  [C] equipo», o «cambio en N s». La vida y la ulti del activo solo se ven en la barrita de 40x5 que hay sobre su cabeza, dibujada con draw_rect (escenas/jugabilidad/jugador/barra_vida.gd, _draw, 40-51). La vida de los que esperan, si han caído y su ulti solo salen al pulsar C, en fichas de texto de 11 y 13 px (_crear_ficha, líneas 79 y 88; _escribir_ficha, 131-153). Los retratos de 64x64 del lote 6 solo se usan en ese panel y en la ventana de caída.
- **Propuesta:** Tres ranuras abajo en el centro con los retratos: la del activo, más grande y encendida; las otras, con su barrita de vida (se curan esperando) y en gris si han caído. Encima de las que esperan, la espera de 10 s como un barrido que se va vaciando, y alrededor de cada una, la carga de su ulti en amarillo (el COLOR_ULTI de barra_vida.gd), que brilla cuando está llena. Al lado, las teclas Q, E y R. Todo sale de señales que ya hay en el bus (equipo_cambiado, ulti_cambiada, personaje_cambiado con la espera), así que se puede hacer en panel_equipo.gd sin tocar la jugabilidad. El cambio de personaje es la mecánica central y así se entiende de un vistazo.
- **Assets:** Marco de ranura de unos 72x72 en tres estados (normal, activo y caído), o uno en grises para teñir. El borde de carga de la ulti en unos 8 fotogramas, más 4 en bucle para «lista». Un icono de reloj o candado de 16x16 para la espera. Se reutilizan los retratos de 64x64 y los iconos de 16x16 de las herramientas (recursos/mejoras/iconos/arma_*.png).

### 4. Paneles, botones y pestañas de pixel art (9-slice) en vez de StyleBoxFlat

Impacto **alto** · esfuerzo **medio** · assets: **sí**

- **Cómo está ahora:** Toda la interfaz sale de EstiloInterfaz.caja() (estilo_interfaz.gd, líneas 74-81): un StyleBoxFlat con un borde de 2 px y las esquinas redondeadas a 6 px (línea 79), que se suavizan y no son pixel art. Lo usan los paneles, los botones (tema(), 33-36), las pestañas (53-56) y todas las ventanas (ventana_centrada, 94-109). «hover» y «focus» son el mismo estilo (líneas 34 y 36): con el ratón encima de un botón y el foco en otro, se ven dos marcados. El lanzador lo copia (lanzador/estilo.gd, caja()). La tarjeta de evolución cambia el border_color del StyleBoxFlat para latir (panel_mejoras.gd, _pintar_bordes, 122-124; tarjeta_evolucion.gd, vestir, líneas 54-56).
- **Propuesta:** Pasar caja() y los estados de los botones a StyleBoxTexture con texturas de 9 trozos (texture_margin_*). Dibujarlas en grises y teñirlas con modulate_color, para que sigan valiendo los colores de ahora (el rojo de la ventana de caída, el verde de la victoria, el color de cada personaje en las evoluciones). El latido de las tarjetas de evolución pasaría a animar modulate_color en vez de border_color. Un estilo de foco distinto del de encima (por ejemplo, con unas esquinas o una flecha) ayuda con el mando. Es el cambio que más hace que la interfaz parezca del mismo juego que los sprites.
- **Assets:** Texturas de 9 trozos en grises: panel (unos 48x48, con 12 px de margen y esquinas tipo chip o remaches), botón (unos 48x24, con 8 px de margen) en normal, encima, pulsado, foco y desactivado, pestaña seleccionada y sin seleccionar (unos 32x24), y una versión de borde grueso para la tarjeta de evolución. Opcional: el marco de la tarjeta de mejora (unos 64x80).
- **Ya apuntado:** documentacio/assets.md (de Alan), tabla «Interfaz»: «Botones: un estilo, tres estados» y «Marco de tarjeta de mejora». Nunca se dibujaron: se hicieron con StyleBoxFlat.

### 5. Pantalla final: avisar si se usó F1 y enseñar con qué se jugó

Impacto **alto** · esfuerzo **medio** · assets: **sí**

- **Cómo está ahora:** pantalla_final.gd (_mostrar, 32-95) solo pone el título, una frase, cuatro datos de texto (tiempo, nivel, eliminados y dificultad; líneas 47-52), los récords batidos y la fila del nombre. No mira estadisticas.trucos. Con el menú de desarrollador, GestorGuardado no deja entrar en el ranking (gestor_guardado.gd, entra_en_ranking, 84-85) y borra los récords batidos (122-124), pero la pantalla no explica por qué: en la defensa, saltando a los jefes con F1, parecerá un fallo. Tampoco hay retratos, ni las mejoras elegidas, ni quién cayó. El campo del nombre es un LineEdit sin estilo, con el gris de Godot (_crear_fila_nombre, 105-108; se ve en capturas/juego/13_victoria_y_ranking.png).
- **Propuesta:** 1) Si trucos es true, una línea: «Partida con el menú de desarrollador (F1): no cuenta para récords ni ranking». 2) Los tres retratos, en gris los caídos (escuchando equipo_cambiado), y la build: los iconos de las mejoras con su nivel, con el diccionario niveles_mejora del HUD pasado como ya se hace con $PanelMejoras.niveles (hud.gd, línea 59). 3) El título como un rótulo de pixel art, de la misma familia que el logo. 4) El LineEdit con el estilo del juego.
- **Assets:** Rótulos «SECTOR ASEGURADO» (verde) y «PROCESO ELIMINADO» (rojo) de unos 512x96, como el logo, con 2 a 4 fotogramas de glitch si se quiere. Lo demás reutiliza los retratos y los iconos de mejora.
- **Ya apuntado:** documentacio/assets.md (de Alan), «Opcional, solo si sobra tiempo», punto 6: «Iconografía para la pantalla de resultados».

### 6. Menú principal: menos texto y los personajes a la vista

Impacto **alto** · esfuerzo **pequeño** · assets: **no**

- **Cómo está ahora:** menu_principal.gd (_ready, 29-79) apila en el centro el logo con glitch, el lema, un panel «CÓMO SE JUEGA» con cuatro líneas de texto (_panel_resumen, 133-143; RESUMEN, 14-18), el récord en una frase larga (_texto_record, 146-154), el selector de dificultad con su explicación, cinco botones y la versión. De fondo, el suelo de la partida (_crear_fondo). No sale ningún personaje ni enemigo: lo primero que ve el tribunal es casi todo texto.
- **Propuesta:** Poner a los tres personajes a los lados (o debajo) del logo, andando en el sitio con sus hojas de 64x72 a x2 (AtlasTexture con las columnas de pasos de la fila de frente, como hace _primer_fotograma en panel_reglas.gd). Dejar el «CÓMO SE JUEGA» en una sola línea, porque ya está entero en REGLAS, y el récord en una línea corta. Opcional: NÚCLEO CERO de fondo, como en la cabecera del lanzador.

### 7. Pausa: pedir confirmación antes de abandonar y enseñar la partida

Impacto **medio** · esfuerzo **pequeño** · assets: **no**

- **Cómo está ahora:** menu_pausa.gd tiene solo CONTINUAR, OPCIONES y MENÚ PRINCIPAL (_ready, 15-40). MENÚ PRINCIPAL va directo a Transicion.cambiar_a (_ir_al_menu, 75-76): un Enter o un click en el botón equivocado tira una partida de 15 minutos. El fondo de la ventana tapa el HUD, así que en pausa no se pueden consultar las mejoras: su descripción solo está en el tooltip de cada icono (icono_mejora.gd, línea 16), y en plena partida nadie lo mira.
- **Propuesta:** Al pulsar MENÚ PRINCIPAL, una ventanita «¿Abandonar la partida? No contará para el ranking» con SÍ y NO, y el foco en NO. Al lado de los botones, un resumen: el tiempo, la dificultad, las mejoras con su icono, nivel y descripción (con niveles_mejora, pasado desde el HUD como a PanelMejoras) y los tres personajes con su vida y la resistencia de su herramienta. Opcional: un recordatorio de los controles.

### 8. HUD de arriba: barra de experiencia, reloj y marcos de las mejoras de pixel art

Impacto **medio** · esfuerzo **pequeño** · assets: **sí**

- **Cómo está ahora:** panel_experiencia.gd (_ready, 27-47) es un PanelContainer con caja() y una ProgressBar de 240x10 hecha con dos StyleBoxFlat (fondo y relleno, líneas 35-45), más «EXP 3 / 25» en 12 px. El reloj es una Label de 30 px sin marco (hud.gd, _crear_reloj, 84-98). Los marcos de la columna de mejoras se dibujan con draw_rect, y los niveles con puntos de 4x4 (icono_mejora.gd, _draw, 24-40). Al lado, las barras de los jefes ya son de pixel art, con marco y relleno en PNG (barra_jefe.gd, _draw, línea 43), y la de experiencia queda pobre en comparación.
- **Propuesta:** Hacer la de experiencia con el mismo método que BarraJefe: un marco PNG con hueco para «NIVEL» y un relleno que se recorta según la experiencia. Se mantienen el llenado y el destello blanco de _destellar, con modulate. Un marco pequeño para el reloj y la cuenta atrás, y un marco de 40x40 para cada icono de mejora, que podría destellar al subir de nivel. La barra de vida sobre el personaje (barra_vida.gd) es de la jugabilidad, pero podría usar el mismo marco en pequeño.
- **Assets:** Marco de la barra de experiencia (unos 272x28) y su relleno (unos 240x8, neón con brillo de píxel). Marco del reloj (unos 140x44). Marco del icono de mejora de 40x40, normal y destellando (2 fotogramas). Opcional: el punto de nivel de 4x4.
- **Ya apuntado:** documentacio/assets.md (de Alan), tabla «Interfaz»: «Barra de vida y barra de XP: marco + relleno». No se hizo.

### 9. Subida de nivel y ruleta: entrada animada, un instante sin poder elegir y sonidos

Impacto **medio** · esfuerzo **pequeño** · assets: **no**

- **Cómo está ahora:** panel_mejoras.gd (_al_subir_nivel, 90-118) enseña la ventana de golpe (línea 116) y da el foco a la primera tarjeta (118). Desde ese momento se puede elegir con 1, 2 o 3 (_unhandled_input, 138-143), con Enter o con click. En partida se hace click a menudo (la ficha del enemigo, ficha_enemigo.gd, 77-82, y la ulti del Mago, que se lanza con click), así que un click justo cuando sube de nivel puede elegir una tarjeta sin haberla leído. Pasar por encima de una tarjeta solo cambia su borde. En audio, solo suenan los clics al pulsar (gestor_audio.gd, _al_anadir_nodo, 131-133). La ruleta gira 3,5 s en silencio (panel_ruleta.gd, DURACION_GIRO, línea 19): solo suena «subir_nivel» al abrir el cofre (gestor_audio.gd, línea 70), y nada al parar (_al_parar, 139-148).
- **Propuesta:** Que las tarjetas entren con un tween corto (escala o deslizamiento, unos 0,25 s, con TWEEN_PAUSE_PROCESS como en panel_experiencia.gd) y no acepten nada durante unos 0,3 s. Que la tarjeta con el ratón encima o con el foco suba unos píxeles. En GestorAudio, además de pressed, conectar mouse_entered y focus_entered de cada botón a un sonido suave, en el mismo _al_anadir_nodo. En la ruleta, un tic cada vez que un sector pasa por la flecha y un sonido de premio al parar: para no llamar a GestorAudio desde la interfaz, que GestorAudio lo calcule al recibir ruleta_abierta o una señal nueva del bus. Los sonidos nuevos se sintetizan con herramientas/generar_audio.gd, como los de ahora.

### 10. Opciones y controles que se ven con el aspecto de Godot, y una opción que no hace nada

Impacto **medio** · esfuerzo **pequeño** · assets: **sí**

- **Cómo está ahora:** El tema solo da color de letra al CheckButton (estilo_interfaz.gd, línea 50): los interruptores de Pantalla completa, CRT y avisos salen con el interruptor gris de Godot (panel_opciones.gd, _casilla, 75-82; se ve en capturas/juego/04_opciones.png). El deslizador de volumen tiene el agarre blanco por defecto, porque el tema no le pone icono (estilo_interfaz.gd, 41-49), y no dice en qué valor está (_deslizador, 63-72). Tampoco tienen estilo propio las barras de desplazamiento (reglas, versiones y novedades del lanzador), el LineEdit del ranking, los tooltips de las mejoras ni los botones desactivados, porque no hay estilo «disabled». La casilla «Avisar de versiones nuevas» (panel_opciones.gd, línea 36) no hace nada desde el lanzador ni en la web, porque el Actualizador no busca (actualizador.gd, _activo, 257-259), y desde la v1.8 solo se juega con el lanzador. En la web sale el botón VERSIONES (menu_principal.gd, línea 109, solo mira --desde-lanzador), que abre una ventana que dice que en la web no hay nada que instalar (panel_versiones.gd, abrir()).
- **Propuesta:** Dar al tema los iconos del interruptor (checked y unchecked) y del agarre del deslizador, con su versión de encima, más el estilo de VScrollBar, LineEdit, TooltipPanel y Button disabled. Poner el porcentaje al lado de cada deslizador. Esconder «Avisar de versiones nuevas» con --desde-lanzador o en la web, y la fila de ACTUALIZAR y VERSIONES también en la web.
- **Assets:** Interruptor de pixel art de unos 40x20, encendido y apagado (más foco). Agarre del deslizador de unos 12x20, normal y encima. Barra de desplazamiento de 9 trozos: carril y agarre de unos 8x24, con 3 px de margen. El LineEdit y el tooltip pueden usar el panel de 9 trozos de la propuesta de los paneles y botones.

### 11. Avisos del HUD en cola y sobre una banda con icono

Impacto **medio** · esfuerzo **pequeño** · assets: **sí**

- **Cómo está ahora:** hud.gd (_avisar, 158-167) tiene una sola Label: un aviso nuevo mata el tween del anterior y lo sustituye (161-163). Un «ÉLITE ELIMINADO: RECOGE EL CORAZÓN Y EL COFRE» (línea 154) puede desaparecer al instante si llega otro aviso (evolución, furia, fase). Los avisos son solo texto de color, y el del élite es «ÉLITE: » más la descripción, sin los iconos de los afijos (línea 69), aunque los iconos existen.
- **Propuesta:** Una cola corta: cada aviso dura al menos 1,5 s, y los urgentes (jefe, furia, fase) pasan delante. Cada aviso, sobre una banda de 9 trozos teñida con su color y con un icono a la izquierda: los iconos de los afijos en el del élite, y uno del jefe, la evolución o la fase en los demás.
- **Assets:** Banda de 9 trozos en grises (unos 64x32, con flechas o chevrones en los extremos). Opcional: 4 fotogramas de entrada. Iconos de 16x16 para jefe, evolución y fase 2; los de los afijos ya están (recursos/enemigos/afijos/iconos/).
- **Ya apuntado:** La parte de los iconos del aviso del élite está en la bitácora, sesión 17, «Siguiente paso», punto 5: «el aviso del HUD del élite sin iconos», para decidirlo con Adam.

### 12. Teclas y botones dibujados, según se juegue con teclado, mando o pantalla táctil

Impacto **medio** · esfuerzo **medio** · assets: **sí**

- **Cómo está ahora:** Las ayudas son texto entre corchetes: «JUGAR  [Enter]» (menu_principal.gd, línea 56), «[1]» en las tarjetas (panel_mejoras.gd, línea 69), «[Q] … [E] … [R] … [C] equipo» (panel_equipo.gd, línea 127), la «R» pintada con fallback_font (barra_vida.gd, línea 51) y todos los CONTROLES en una sola línea (panel_reglas.gd, línea 43). Con mando siguen saliendo las teclas. Además, con mando no se puede volver al personaje anterior (personaje_anterior solo tiene la Q: project.godot, líneas 74-78) ni abrir el equipo (solo con la C física: panel_equipo.gd, línea 98). En el móvil, control_tactil.gd pinta círculos con texto («CAMBIAR», «II», «ULTI»; _pintar y _boton, 123-139), no tiene botón para el anterior ni para el equipo (_al_tocar, 79-87), y el HUD sigue enseñando [Q], [E] y [C].
- **Propuesta:** Un juego de iconos de teclas y de botones del mando, y una función pequeña que elija cuáles enseñar según el último evento (InputEventJoypadButton o InputEventKey). Usarla en el HUD, las tarjetas, los botones y una pestaña de CONTROLES con un esquema en vez de la línea. Añadir un botón del mando para personaje_anterior (LB o X) y para el equipo, metiéndolos al empezar si faltan, como teclas_antiguas.gd, para no subir EJECUTABLE_MINIMO. En la web táctil: botones de pixel art con icono, uno para el anterior y otro para el equipo, y sin las teclas en el HUD.
- **Assets:** Teclas de unos 16x16 o 20x20: Q, E, R, C, Tab, Esc, Enter, 1, 2, 3, WASD, flechas, F1, F3, y los botones izquierdo y derecho del ratón. Botones del mando: A, B, X, Y, LB, RB, Start y el stick. Para el táctil: botones de unos 96x96, normal y pulsado, con icono (cambiar, anterior, ulti, pausa y equipo), base del joystick de unos 160x160 y palanca de 64x64.
- **Ya apuntado:** documentacio/presentacion.md, apartado 8 («Qué mejoraríamos»): «controles remapeables». Está relacionado, pero no es lo mismo.

### 13. Reglas: partir los textos largos y ponerles dibujos

Impacto **medio** · esfuerzo **medio** · assets: **sí**

- **Cómo está ahora:** En panel_reglas.gd, Kernel Panic es un solo párrafo de unas 900 letras (_enemigos, línea 147), y NÚCLEO CERO, de unas 800 (línea 149). Los apartados de «Cómo se juega» (COMO_SE_JUEGA, 33-44) no tienen icono: en _fila (líneas 192-197) se pone un ColorRect de 10x10 del color. Los CONTROLES van en una línea con separadores «·» (línea 43).
- **Propuesta:** Partir a cada jefe en una línea corta por ataque, cada una con el primer fotograma de su sprite, que ya existen: jefe_jaula_aviso.png, jefe_rafaga.png, jefe_pisoton_onda.png, jefe_final_aviso_linea, zona y diana, jefe_final_portal.png, jefe_final_hielo.png y jefe_final_ancla_*.png (_primer_fotograma ya sirve). Un icono de 16x16 en cada apartado de «Cómo se juega» en vez del cuadrado. Los CONTROLES, con los iconos de las teclas de la propuesta anterior.
- **Assets:** Unos 7 iconos de 16x16 para los apartados: objetivo, dificultad, el malware se adapta, cambia de personaje, ulti, ficha del enemigo y controles. Experiencia y premio de los élites pueden usar fragmento_datos.png y cofre.png. Los ataques reutilizan los sprites que ya hay.

### 14. Lanzador: barra de descarga, fondo y lista de versiones más visual

Impacto **medio** · esfuerzo **pequeño** · assets: **sí**

- **Cómo está ahora:** lanzador/lanzador.gd (_construir, 45-104): la cabecera de 960x260 y, debajo, un ColorRect liso (47-50). La descarga solo se ve como texto («Descargando...  45 %», línea 35). El desplegable marca las versiones sin descargar con «· descargar» (_nombre, 135-138). La lista del desplegable no tiene estilo de encima y sale el gris de Godot (lanzador/estilo.gd, 33-35, solo pone el panel y los colores de letra). Las novedades son una Label de texto plano. Desde la v1.8, el lanzador es lo primero que se ve tras instalar.
- **Propuesta:** Una barra de progreso con el estilo de las barras nuevas, en vez del porcentaje en texto. De fondo, la placa base en un PNG estático y oscurecido, en lugar del color liso, porque el shader del suelo es del otro proyecto. Un icono por versión: descargada, por descargar o descargando. El estilo de encima del PopupMenu. JUGAR con el botón grande de 9 trozos y la misma fuente que el juego (las propuestas de la fuente y de los botones).
- **Assets:** Fondo de placa base de 960x340 o una tesela de 256x256, oscurecida. Iconos de 16x16: descargada (marca), por descargar (flecha) y descargando (2 a 4 fotogramas). Marco y relleno de la barra de progreso (unos 400x16).

### 15. Ranking con retratos, medallas y la partida recién guardada marcada

Impacto **bajo** · esfuerzo **pequeño** · assets: **sí**

- **Cómo está ahora:** panel_ranking.gd (abrir, 45-63) es una tabla de texto de 8 columnas (COLUMNAS, línea 12). El personaje sale como nombre, no hay nada que distinga los tres primeros, y al volver de la pantalla final no se marca la partida que se acaba de guardar, aunque anadir_al_ranking devuelve el puesto (pantalla_final.gd, _guardar_en_ranking, línea 119).
- **Propuesta:** Un mini retrato en vez del nombre del personaje, medallas de oro, plata y bronce para los tres primeros, y la última partida guardada resaltada (con latido) cuando se abre el ranking justo después.
- **Assets:** Medallas de 16x16 de oro, plata y bronce. Mini retratos de 32x32 de los tres personajes: los de 64x64 reducidos a la mitad con filtro nearest pierden píxeles, mejor dibujarlos.

## El sonido y la sensación de juego

### 1. Tiempo de golpe (hit stop) en los momentos fuertes

Impacto **alto** · esfuerzo **pequeño** · assets: **no**

- **Cómo está ahora:** No hay ninguno. Engine.time_scale solo lo cambia el menú F1 (panel_trucos.gd, _poner_velocidad, l. 191), y _exit_tree lo devuelve a 1. La muerte de un élite (enemigo_elite.gd, _al_morir, l. 171), las furias de Kernel Panic (jefe.gd, _enfurecer, l. 292), el escudo roto (jefe_final.gd, _al_romper_escudo, l. 252), los cambios de forma de NÚCLEO CERO (_transformar, l. 244) y el lanzamiento de una ulti (ultis.gd, lanzar) pasan sin ningún frenazo: solo hay partículas, sonido y, en algunos, un tirón de cámara.
- **Propuesta:** Un nodo pequeño en la partida (por ejemplo escenas/jugabilidad/efectos/tiempo_golpe.gd, sin class_name) que escucha el bus y congela el juego unas centésimas. Guarda Engine.time_scale (para respetar la velocidad x2 del F1), lo pone a 0,05 y lo devuelve con get_tree().create_timer(segundos, true, false, true). El cuarto argumento, ignore_time_scale, existe en 4.7.2 (comprobado). Valores orientativos: 0,05 s al morir un élite (enemigo_muerto 'elite') y en ulti_lanzada; 0,1 s en jefe_furia_cambiada, en jefe_final_forma_cambiada y en el escudo roto (cuando tenga su señal, mejora del escudo); 0,15 s al morir cada jefe. Con --fixed-fps 60 el simulador sigue siendo determinista, pero el ritmo cambia unos fotogramas: hay que volver a pasarlo. Solo código, unas tres líneas por evento, fácil de defender.

### 2. El escudo de NÚCLEO CERO, que se oiga: golpe bloqueado, ancla rota y escudo roto

Impacto **alto** · esfuerzo **medio** · assets: **sí**

- **Cómo está ahora:** Solo suena al levantarse y al volver a cerrarse: escudo_jefe_final.gd emite jefe_final_ataco('escudo') en levantar() (l. 80) y al cerrarse por tiempo (l. 122), y gestor_audio.gd lo toca con 'evolucion' a 0,6 (SONIDO_ATAQUE, l. 32). Pegar a un ancla con la herramienta equivocada solo saca el 0 rojo (ancla_escudo.gd, danar_en_area, l. 79-83). Romper un ancla no avisa de nada (l. 91-93). Cuando estalla la burbuja, se emite la señal roto (escudo_jefe_final.gd, l. 109), que solo escucha jefe_final.gd (_al_romper_escudo, l. 252) para aturdirle: ni sonido ni cámara. Es la mecánica que obliga a cambiar de personaje, la que más hay que entender.
- **Propuesta:** Tres señales nuevas en el bus, emitidas desde ancla_escudo.gd y escudo_jefe_final.gd (por ejemplo ancla_bloqueada, ancla_rota y escudo_roto; apuntarlas en GEMINI.md), con un sonido cada una:
- golpe bloqueado: un «tunk» sordo (cuadrada grave de 120 a 90 Hz, 0,08 s), con la misma espera de 0,3 s que el 0 rojo (ESPERA_CERO)
- ancla rota: un crujido (ruido más un triángulo que baja)
- escudo roto: un cristal que se rompe (ruido de 0,5 s más un arpegio agudo que baja)

El escudo roto, además, con tiempo de golpe y sacudida (las dos primeras mejoras de cámara y tiempo). Se sintetiza con lo que ya tiene generar_audio.gd (_nota, _mezclar, _arpegio).
- **Assets:** 3 efectos nuevos (ancla_bloqueada, ancla_rota y escudo_roto), sintetizados por código en generar_audio.gd. Sin dibujos.
- **Ya apuntado:** Solo la prueba: bitácora, sesión 18, «Siguiente paso» punto 1 (ver jugando si el escudo se entiende), y requisitos_y_estado.md, punto 2 (probar el escudo con sus anclas). Los sonidos no están apuntados.

### 3. Ultis y herramientas evolucionadas con sonido propio, y NÚCLEO CERO que suene a lo que roba

Impacto **alto** · esfuerzo **medio** · assets: **sí**

- **Cómo está ahora:** En gestor_audio.gd, _al_lanzar_ulti (l. 152-154), las tres ultis suenan igual: 'evolucion' + 'explosion' a 0,8. Y eso que una es un rayo de 0,6 s, otra un giro de 1,5 s y otra una tormenta de 10 mini rayos (constantes y lanzar() de ultis.gd). Cuando la carga se llena (ulti_cambiada) no suena nada: solo parpadea la barrita y sale una «R» (barra_vida.gd, l. 48-51). NÚCLEO CERO roba las ultis, pero su 'rayo', que es la del Mago, suena con 'escaner', la herramienta del Segador (SONIDO_ATAQUE, l. 27). Las evoluciones suenan como su herramienta base: analisis_heuristico.tres tiene sonido = 'escaner', firewall_perimetral.tres 'firewall' y ping_inundacion.tres 'ping'.
- **Propuesta:** Tres sonidos de ulti ajustados a sus tiempos, que son constantes fijas en ultis.gd:
- ulti_rayo: una sierra que sube y zumba 0,6 s, con los tres golpes de RAYO_GOLPES marcados
- ulti_giro: siete barridos de triángulo, uno cada GIRO_CADA (0,2 s)
- ulti_tormenta: un trueno de ruido y seno grave, con los 10 chasquidos ya colocados en el WAV a 0,3 + i·0,08 s, sin señal por mini rayo

_al_lanzar_ulti elige el sonido según personaje.ulti. En SONIDO_ATAQUE, NÚCLEO CERO usa los mismos (rayo, torbellino y tormenta) a un tono más grave: así se oye que te roba los ataques.

Además, un «ulti lista» corto cuando la carga del activo llega a 1 en ulti_cambiada (recordando la carga anterior para que suene una sola vez). Para las evoluciones, un WAV por evolución y cambiar el campo sonido de sus .tres; o, más barato, un campo tono_sonido en DatosArma, que no añade class_name.
- **Assets:** Unos 7 efectos sintetizados por código: ulti_rayo, ulti_giro, ulti_tormenta, ulti_lista y uno por evolución (firewall_perimetral, analisis_heuristico y ping_inundacion). Sin dibujos.

### 4. Música propia para la fase 2 y para NÚCLEO CERO, y bucles más largos

Impacto **alto** · esfuerzo **medio** · assets: **sí**

- **Cómo está ahora:** Hay tres pistas, todas de generar_audio.gd: _musica_menu (24 s), _musica_partida (29,1 s) y _musica_jefe (12,8 s); las duraciones salen del tamaño de los WAV. La fase 2 es la música de la partida a 0,85 de tono (gestor_audio.gd, l. 84), y NÚCLEO CERO, la del jefe a 1,1 (_al_aparecer_jefe_final, l. 163-165). El clímax repite, por tanto, un bucle de 12 s, y en el simulador hay partidas que llegan al límite de 240 s contra él (bitácora, sesión 18). Los cambios de forma no cambian la música: _al_endurecerse_jefe solo toca la alarma y la explosión. Al acabar, _al_terminar (l. 188-191) para la música con stop() y suena un arpegio de 0,84 s (victoria) o de 0,9 s (derrota). La pantalla final se queda en silencio.
- **Propuesta:** Con el mismo secuenciador de generar_audio.gd (_secuencia y _bateria):
- una musica_fase2 «dañada»: tonalidad menor más oscura, bajo en sierra y pasos que se saltan como un disco rayado (la semilla fija la hace siempre igual)
- una musica_jefe_final de 40-60 s en dos partes (A y B)
- la del jefe del minuto 10, alargada con una segunda sección

Opcional: que cada forma de NÚCLEO CERO cambie de pista o añada batería (con jefe_final_forma_cambiada). Además, victoria y derrota de 3-5 s y un bucle tranquilo en la pantalla final. Solo hay que añadir las funciones al generador, poner los nombres en gestor_audio.gd y marcar edit/loop_mode=2 en su .import, como explica _guardar. Ya se importan comprimidas (compress/mode=2), así que pesan poco en el .pck.
- **Assets:** 2 o 3 pistas nuevas sintetizadas por código (musica_fase2, musica_jefe_final y, si se quiere, musica_resultados), y la victoria y la derrota más largas. Sin dibujos.

### 5. Que se note cuando el malware se adapta (el elemento diferencial)

Impacto **alto** · esfuerzo **pequeño** · assets: **sí**

- **Cómo está ahora:** resistencia_malware.gd emite resistencia_cambiada(arma, valor) en _cambiar (l. 81) cada vez que el análisis de cada 20 s (_analizar, intervalo_analisis) sube o baja una resistencia, pero nadie la escucha: ningún script ni escena se conecta. La adaptación solo se nota poco a poco: el anillo del arma se tiñe de rojo (aura_arma.gd, l. 104), los números se van poniendo rojos (pool_numeros_flotantes.gd, _draw, l. 78) y sale en la ficha y en el panel del equipo. No hay sonido ni aviso: el factor diferencial del juego no tiene un momento visible para la demo.
- **Propuesta:** Pasar la señal al bus (por ejemplo malware_adaptado(arma, resistencia), emitida en _cambiar solo cuando la resistencia sube) y, con ella:
- en GestorAudio, un sonido de «adaptación», tipo glitch: una cuadrada que baja de 800 a 200 Hz a trompicones, con ruido
- en el HUD, solo si es la herramienta del personaje activo, un aviso con _avisar: «EL MALWARE SE ADAPTA A TU FIREWALL: 30 %», en rojo
- opcional: un destello rojo del anillo en aura_arma.gd

Así, en la defensa, se puede señalar el momento exacto en que pasa. Apuntar la señal en GEMINI.md.
- **Assets:** Un efecto sintetizado por código (adaptacion). Sin dibujos.

### 6. Una sola sacudida de cámara, según el golpe y con opción para quitarla

Impacto **medio** · esfuerzo **medio** · assets: **no**

- **Cómo está ahora:** La cámara se mueve de tres maneras distintas:
- controlador_jugador.gd, _al_recibir_dano (l. 34-46): un único tirón de 6 px en una dirección al azar (randf(), l. 42) que vuelve en 0,3 s, igual con 5 de daño que con 30
- sacudir() (l. 53-59): un tirón siempre hacia abajo; lo usa espectaculo_jefe.gd (l. 66, 72 y 94)
- jefe_final.gd, _temblar() (l. 273): escribe directamente en camara.offset con su propio tween de seis desplazamientos fijos. Si al jugador le dan mientras tiembla, dos tweens se pelean por el mismo offset, que es justo lo que el comentario de sacudir() dice evitar.

Las ultis (ultis.gd, lanzar), la explosión del élite (enemigo_elite.gd, _explotar, l. 195) y la aparición de NÚCLEO CERO no mueven la cámara. Tampoco hay opción para desactivarla en panel_opciones.gd.
- **Propuesta:** Una sola función, sacudir(fuerza) en controlador_jugador.gd, con un «trauma» que se suma y se apaga con el tiempo: un temblor de varias oscilaciones que se van haciendo pequeñas, en vez de un tirón. Para no gastar el azar de la partida, un RandomNumberGenerator propio con semilla fija. El golpe al jugador la llama con una fuerza según el daño (por ejemplo clampf(cantidad / 5, 3, 12)), jefe_final._temblar() pasa a llamar a _jugador.sacudir(), y se añade en ulti_lanzada, elite_exploto y jefe_final_aparecio. También una casilla «Sacudir la cámara» en panel_opciones.gd, con el mismo _casilla() que el CRT y una clave nueva en OPCIONES_POR_DEFECTO de gestor_guardado.gd. Al quitar el randf() de la l. 42 cambian las partidas del simulador: hay que medir de nuevo la referencia. Solo código.

### 7. Avisos sonoros de los ataques de los jefes, para esquivar de oído

Impacto **medio** · esfuerzo **medio** · assets: **sí**

- **Cómo está ahora:** Kernel Panic:
- el pisotón solo suena al cerrarse la jaula, cuando ya no se puede salir (jaula_jefe.gd, _physics_process, l. 112-114, 'explosion' a 0,6), no al empezar el aviso de 0,5 s
- la embestida no suena nada (jefe.gd, estados AVISO y EMBESTIDA, l. 213-223)
- la ráfaga son 12 proyectiles con un único 'ping' de 0,05 s a 0,8 (rafaga_jefe.gd, disparar, l. 57)
- la rotura de la jaula y el golpe de la columna al aparecer no tienen sonido; el golpe sí sacude la cámara (espectaculo_jefe.gd, l. 93-94)

NÚCLEO CERO: cada ataque suena una sola vez, al empezar (ataques_jefe_final.gd, l. 145), y el hielo usa 'ping' a 0,6, casi el mismo blip que el disparo del Mago.
- **Propuesta:** Usar la misma señal jefe_ataco con nombres nuevos y añadirlos a SONIDO_ATAQUE: 'aviso_pisoton' (en jaula.empezar), 'aviso_embestida' (al entrar en AVISO), 'embestida', 'jaula_rota' y 'aparicion' (en GOLPE_APARICION). Sonidos:
- un aviso que sube durante los 0,5 s de DURA_AVISO; si acaba justo cuando la jaula se cierra, se aprende el ritmo
- un rugido de sierra para la embestida
- una ráfaga de 12 golpecitos
- un golpe grave para la aparición
- un cristal que cae para el hielo de NÚCLEO CERO

Todo se puede sintetizar con el generador.
- **Assets:** 5 o 6 efectos sintetizados por código: aviso (una subida de 0,5 s), embestida, rafaga, jaula_rota, aparicion_jefe y hielo. Sin dibujos.
- **Ya apuntado:** Solo probar cómo suenan el pisotón, la ráfaga y la rabia: bitácora, sesión 17, «Siguiente paso» punto 2 (último guion), y sesión 18, «Siguiente paso» punto 1. Hacerles sonidos propios no está apuntado: se pusieron «con efectos que ya había» (sesión 17).

### 8. Música por capas que crece con la partida

Impacto **medio** · esfuerzo **medio** · assets: **sí**

- **Cómo está ahora:** musica_partida es un único WAV de 29 s en bucle (generar_audio.gd, _musica_partida). La melodía entra siempre en la segunda vuelta (vuelta == 1), igual en el minuto 1 que en el 9:50 con mil enemigos en pantalla. gestor_audio.gd tiene un solo AudioStreamPlayer de música (_musica), que cambia de pista con _poner_musica.
- **Propuesta:** Guardar por separado las pistas que _musica_partida ya construye (bajo, arpegio, melodía y batería) y reproducirlas a la vez con AudioStreamSynchronized (existe en 4.7.2, con set_stream_count, set_sync_stream y set_sync_stream_volume; comprobado). Con tiempo_partida, GestorAudio va subiendo capas: hasta el minuto 3, solo bajo y arpegio; desde el 3, la batería; desde el 6, la melodía; en el último minuto antes del jefe, todo. Se oye que la partida se pone seria sin cambiar de canción. Si se hace junto con la música propia de la fase 2, esa puede ir igual.
- **Assets:** Partir musica_partida en 3 o 4 WAV (una pista por instrumento) con el mismo generar_audio.gd. No hay nada nuevo que componer.

### 9. Música amortiguada (filtro de paso bajo) mientras se elige

Impacto **medio** · esfuerzo **pequeño** · assets: **no**

- **Cómo está ahora:** gestor_audio.gd, _al_pausar (l. 182-185): con el menú de pausa la música baja a -12 dB, y nada más. Las pausas que pone la jugabilidad (subir de nivel, ruleta del cofre y ventana de caída de un personaje) no emiten juego_pausado, así que la música sigue a todo volumen. default_bus_layout.tres tiene los buses Musica y Efectos sin ningún efecto.
- **Propuesta:** En GestorAudio._ready, añadir un AudioEffectLowPassFilter al bus Musica con AudioServer.add_bus_effect (por código, sin tocar el .tres; cutoff_hz de unos 700). Se enciende con set_bus_effect_enabled al pausar y en jugador_subio_nivel, ruleta_abierta y personaje_caido, y se apaga con mejora_seleccionada, personaje_elegido y juego_pausado(false). La música suena «detrás de un cristal» mientras eliges y separa claramente el menú de la acción. Con varias subidas de nivel en cola, se apaga y se enciende en el mismo fotograma, así que no se nota. Solo código, unas 10 líneas; la API está comprobada en 4.7.2.

### 10. Aviso de poca vida

Impacto **medio** · esfuerzo **pequeño** · assets: **sí**

- **Cómo está ahora:** salud_jugador_cambiada solo la escucha el panel de depuración (panel_depuracion.gd, l. 41). Con poca vida, lo único que cambia es el color de la barrita sobre la cabeza, de verde a rojo (barra_vida.gd, _draw, l. 43). No suena nada ni cambia la pantalla, y con cientos de enemigos alrededor esa barra de 40x5 px se pierde.
- **Propuesta:** En GestorAudio, con salud_jugador_cambiada por debajo del 25 % (y por encima de 0), un latido en bucle: dos golpes de seno grave (60 a 40 Hz) cada 0,8 s, más rápido por debajo del 10 %. Se para al curarse, al cambiar a un personaje con más vida o al acabar la partida. Opcional en lo visual: que la barra de vida lata, como ya late la carga de la ulti en el mismo _draw. Aquí sí sirve que la señal cambie también al cambiar de personaje: lo que importa es la vida del que juega.
- **Assets:** Un efecto sintetizado por código (latido, de unos 0,4 s, repetido con un Timer). Sin dibujos.

### 11. Recoger cosas: corazón, cofre, ruleta y gemas con su sonido

Impacto **medio** · esfuerzo **medio** · assets: **sí**

- **Cómo está ahora:** premios_elite.gd, _recoger (l. 72-80): el corazón cura con una animación y un «+N» verde, pero no emite nada al bus y no suena. El cofre emite cofre_recogido (l. 115), que GestorAudio no escucha; después, ruleta_abierta suena con 'subir_nivel' (gestor_audio.gd, l. 70), el mismo sonido que subir de nivel. La ruleta gira 3,5 s en silencio (panel_ruleta.gd, DURACION_GIRO l. 19, y el tween de _al_abrir, l. 126); al pararse (_al_parar, l. 139) solo late el icono. Las gemas: experiencia_ganada siempre suena 'gema' al mismo tono (gestor_audio.gd, l. 68), sin usar la cantidad.
- **Propuesta:** - Corazón: una señal corazon_recogido en el bus, emitida en _recoger, y un sonido «curar» (arpegio suave de triángulo que sube).
- Cofre: un «clac» con brillo en cofre_recogido.
- Ruleta: un «tic» cada vez que el disco pasa un sector. En panel_ruleta._process se compara floori(rotation / GRADOS_SECTOR) con el anterior y se emite una señal ruleta_tic; como el giro frena, los tics se espacian solos. Y un «premio» al pararse.
- Gemas, solo código: subir el tono un semitono por cada gema recogida en menos de 0,3 s, hasta una octava, y volver al tono normal al parar, como una escala.

Apuntar las señales nuevas en GEMINI.md.
- **Assets:** 4 efectos sintetizados por código: curar, cofre, ruleta_tic (muy corto, tipo clic) y premio. Lo de las gemas no necesita nada. Sin dibujos.

### 12. Números de daño con más pegada

Impacto **medio** · esfuerzo **pequeño** · assets: **no**

- **Cómo está ahora:** En pool_numeros_flotantes.gd todos los números son iguales:
- tamaño 15 fijo (tamano_fuente, l. 12)
- con ThemeDB.fallback_font (l. 30) en vez de la fuente monoespaciada del resto de la interfaz (EstiloInterfaz.tema())
- sin contorno
- alineados a la izquierda desde el punto del golpe (_draw, l. 79-87, HORIZONTAL_ALIGNMENT_LEFT con ancho -1), así que quedan a la derecha del enemigo
- suben a velocidad constante

En la horda salen en la posición exacta del enemigo (gestor_enemigos.gd, l. 165), y los golpes seguidos al mismo enemigo se pintan unos encima de otros. Los élites y los jefes sí los desplazan al azar.
- **Propuesta:** En el mismo _draw, sin nodos nuevos:
- un «pop» al nacer: ×1,5 los primeros 0,08 s y después su tamaño
- tamaño según el golpe (por ejemplo 13 + 4·log10(daño), con tope)
- centrado (restando la mitad de get_string_size)
- contorno negro con draw_string_outline antes del texto (existe en 4.7.2; comprobado)
- la fuente del tema
- una subida que frena

Para separar los de la horda, un pequeño desplazamiento en x con un RandomNumberGenerator propio, así no se gasta el azar de la partida y el simulador repite las mismas partidas. Solo código.

### 13. Subir de nivel con más ceremonia y sonido al moverse por los menús

Impacto **medio** · esfuerzo **pequeño** · assets: **sí**

- **Cómo está ahora:** panel_mejoras.gd, _al_subir_nivel (l. 90): la ventana aparece de golpe (_ventana.visible = true), con las tres tarjetas a la vez; solo late la de evolución. Siempre suena 'subir_nivel' (gestor_audio.gd, l. 69), haya evolución o no. Los botones solo suenan al pulsarlos: _al_anadir_nodo (l. 131-133) conecta pressed a 'clic'. Moverse entre tarjetas con el mando o pasar el ratón por encima no da ninguna respuesta.
- **Propuesta:** - Que las tarjetas entren una detrás de otra: tween de escala de 0,8 a 1 y de opacidad, con 0,06 s de desfase. El panel ya funciona en pausa, así que su tween también.
- En GestorAudio, si las opciones traen una DatosMejora.Efecto.EVOLUCIONAR_ARMA, un sonido más grande en lugar de 'subir_nivel'.
- En _al_anadir_nodo, conectar también focus_entered y mouse_entered a un «foco» muy suave; sirve para todos los menús a la vez. El grab_focus() que pone el foco al abrir lo haría sonar siempre: hay que saltarse ese primero.
- **Assets:** 2 efectos sintetizados por código: foco (un blip de 0,02 s, más suave que el clic) y evolucion_disponible (un arpegio largo, o 'evolucion' a otro tono). Sin dibujos.

### 14. Caída de un personaje y derrota con cámara lenta y «cinta que se para»

Impacto **medio** · esfuerzo **pequeño** · assets: **sí**

- **Cómo está ahora:** cambio_personaje.gd, _al_caer (l. 169-180): al caer el activo, el juego se pausa al instante y sale la ventana para elegir quién sigue. Suena 'explosion' (gestor_audio.gd, l. 75), el mismo sonido que la muerte de un élite o de un jefe. Al caer el último, equipo_derrotado lleva a partida_terminada en el mismo fotograma, y _al_terminar (l. 188-191) corta la música en seco con stop() antes del arpegio de derrota.
- **Propuesta:** Antes de pausar, un momento: 0,5 s a cámara lenta (Engine.time_scale a 0,25, con un create_timer que ignore la escala, como en el tiempo de golpe), un estallido de partículas del color del personaje (pool_particulas.estallido, que ya existe) y un sonido propio de «proceso terminado» (un glitch que baja). En la derrota final, que la música no se corte en seco sino que «se pare la cinta»: un tween de _musica.pitch_scale de 1 a 0,3 en 0,8 s antes del stop(). Funciona con el juego pausado porque GestorAudio va en PROCESS_MODE_ALWAYS, y _poner_musica ya devuelve el tono a 1 en la siguiente partida. Hay que probar que en esos 0,5 s no pasa nada raro (el arma sigue disparando) y volver a pasar el simulador.
- **Assets:** Un efecto sintetizado por código (caida). Sin dibujos.

### 15. Destello de los jefes que no los deje en blanco

Impacto **bajo** · esfuerzo **pequeño** · assets: **no**

- **Cómo está ahora:** sprite_destello.gd, destellar() (l. 25-26), vuelve el destello al máximo con cada golpe. Kernel Panic (jefe.gd, danar_en_area, l. 151), NÚCLEO CERO (jefe_final.gd, l. 130) y los élites reciben varios golpes por segundo (el Firewall cada 0,5-0,6 s, cada Ping, las ultis), así que se ven casi siempre blancos y se pierde su dibujo.
- **Propuesta:** Dos cambios pequeños en sprite_destello.gd: no volver a destellar hasta que acabe el destello anterior y pase un respiro (por ejemplo 0,1 s), y un @export de intensidad máxima (0,6 en los jefes, 1 en los élites) que multiplique el parámetro destello. Cada golpe se sigue notando y el jefe conserva su color. Solo código.
- **Ya apuntado:** Bitácora, sesión 18, «Problemas encontrados y cómo se resolvieron», primer punto: el jefe del minuto 10 sale casi blanco en algunas capturas por el destello; está anotado para mirarlo jugando.

## La jugabilidad y el contenido

### 1. Corregir los textos de las reglas que ya no cuadran con el juego

Impacto **medio** · esfuerzo **pequeño** · assets: **no**

- **Cómo está ahora:** Las reglas sacan las descripciones de los .tres (panel_reglas.gd, _personajes() y _mejoras()). Lo que no cuadra: 1) recursos/personajes/datos/espadachin.tres dice que el robo de vida cura «hasta 3 de vida», pero ROBO_MAXIMO en gestor_armas.gd vale 1.5 desde el 22/10. 2) Las tres evoluciones (evolucion_firewall/ping/escaner.tres) dicen «El malware no tiene resistencia contra él», pero resistencia_malware.gd (_analizar) no deja fuera ningún arma: la evolución empieza en 0 % y luego se adapta como las demás. 3) mago.tres dice que el Ping salta «hasta cinco» (ping.tres, rebotes = 4, o sea, golpea a 5) y evolucion_ping.tres que «salta hasta cinco veces» (rebotes = 5, golpea a 6): leído así, parece que la evolución no mejora. 4) El texto de NÚCLEO CERO (panel_reglas.gd, _enemigos()) no dice que en la amalgama levanta el escudo cada 35 s (ESCUDO_CADA en jefe_final.gd, _luchar). 5) La ficha de un ancla enseña «Resiste a tu X: N %» (ficha_enemigo.gd, _texto_resistencia), aunque ancla_escudo.gd (danar_en_area) anula esa resistencia. 6) vida.tres dice «+25 de integridad máxima», pero se suma a los tres personajes (cambio_personaje.gd, aumentar_vida_maxima).
- **Propuesta:** Repasar esos textos: robo de vida «hasta 1,5»; evoluciones «el malware empieza sin resistencia contra él»; Ping «golpea hasta 5 enemigos» y la evolución «hasta 6»; NÚCLEO CERO «en su última forma vuelve a cerrarse cada 35 s»; Memoria redundante «+25 de integridad para los tres». En la ficha del ancla, en vez del porcentaje, poner «Solo la rompe el Mago» (con una clave más en el diccionario que devuelve ficha() y un if en _mostrar). Casi todo son .tres y una línea de código. Revisar también el manual por si repite alguno de estos datos.

### 2. Avisar cuando el malware se adapta (el elemento diferencial tiene que verse)

Impacto **alto** · esfuerzo **pequeño** · assets: **no**

- **Cómo está ahora:** resistencia_malware.gd sube la resistencia cada 20 s (_analizar) y emite resistencia_cambiada, pero es una señal del propio nodo y no la escucha nadie. Solo se nota en el tinte de los números de daño (pool_numeros_flotantes.gd: con el 50 % quedan a medio camino del rojo, en naranja) y en el del anillo (aura_arma.gd, línea 104). El porcentaje solo aparece en el panel del equipo, que se abre con C (panel_equipo.gd, _escribir_ficha), o en la ficha del enemigo. La línea fija de abajo (panel_equipo.gd, _escribir_linea) no lo enseña, y al subir no suena nada.
- **Propuesta:** Que el HUD se conecte a resistencia_cambiada a través del grupo resistencia_malware (como ya hace panel_equipo.gd en la línea 68, así que no hace falta otra señal en el bus). Cuando suba la de la herramienta activa: aviso grande «EL MALWARE SE ADAPTA AL FIREWALL: 30 % · CAMBIA CON E / Q» y un sonido que ya existe (por ejemplo alarma_elite con el tono más grave). En la línea de abajo, junto al nombre de la herramienta, «resiste 30 %» en rojo cuando sea mayor que 0. Así el tribunal ve el elemento diferencial sin tener que leer las reglas. No cambia el equilibrio.

### 3. Que la partida no se pierda del ranking si no se pulsa GUARDAR

Impacto **medio** · esfuerzo **pequeño** · assets: **no**

- **Cómo está ahora:** pantalla_final.gd: si la partida entra en el top 10, sale el campo del nombre (_crear_fila_nombre), pero solo se guarda en _guardar_en_ranking, al pulsar GUARDAR o Enter en el campo. _reintentar() (línea 137) e _ir_al_menu() (línea 142) cambian de escena sin guardar nada: quien pulse REINTENTAR o MENÚ con el ratón pierde su puesto en el ranking sin enterarse.
- **Propuesta:** En _reintentar() y en _ir_al_menu(), si la fila del nombre sigue sin guardar (_nombre != null), llamar antes a _guardar_en_ranking(), que ya pone «Anónimo» si el campo está vacío. Son dos líneas.

### 4. Pausar solo cuando la ventana pierde el foco

Impacto **medio** · esfuerzo **pequeño** · assets: **no**

- **Cómo está ahora:** menu_pausa.gd solo se abre con la acción pausar (_unhandled_input, línea 43), y nada escucha la pérdida de foco: buscando FOCUS_OUT o NOTIFICATION_APPLICATION en escenas/ y globales/ no sale nada. Si en la defensa se cambia de ventana para enseñar el código, o en la web se cambia de pestaña, la partida sigue y la horda acaba con el personaje.
- **Propuesta:** Añadir _notification(what) en menu_pausa.gd: con NOTIFICATION_APPLICATION_FOCUS_OUT, si no está ya en pausa, llamar a _alternar_pausa(). Esa función ya comprueba que no pise otras pausas (subida de nivel, caída, fin de partida). Antes, comprobar el nombre de la constante en la API de 4.7.2 y que en headless no salte (el simulador no usa el menú de pausa).

### 5. No ofrecer la evolución de un personaje caído

Impacto **medio** · esfuerzo **pequeño** · assets: **no**

- **Cómo está ahora:** sistema_niveles.gd, _evolucion_disponible() (línea 160), solo comprueba _agotadas y cuántas veces se ha cogido la mejora que pide, no si ha caído el personaje de esa herramienta. Como la evolución «sale siempre, y la primera» (_sortear_opciones) y también en la ruleta (_sortear_sectores, línea 149), con el Mago caído y Multihilo ×3, Ping de inundación ocupa una de las tres tarjetas en cada subida hasta que se elige. Y elegirla no sirve de nada: cambio_personaje.gd, evolucionar() (línea 159), cambia el arma del caído, avisa «EVOLUCIÓN» en el HUD y suena.
- **Propuesta:** Una función en cambio_personaje.gd, por ejemplo puede_evolucionar(base), que devuelva si la herramienta base la lleva un personaje que no ha caído, y que _evolucion_disponible() se salte las que den false. Si algún día se revive a alguien (F1, revivir_todos), su evolución vuelve a salir sola.

### 6. El escudo de NÚCLEO CERO: explicar qué hacer y que las anclas no dependan solo del color

Impacto **alto** · esfuerzo **pequeño** · assets: **sí**

- **Cómo está ahora:** Al levantarse el escudo (escudo_jefe_final.gd, levantar()) se emite jefe_final_ataco("escudo"), pero esa señal solo la usa el audio (gestor_audio.gd, SONIDO_ATAQUE). hud.gd no la escucha, así que nada dice en pantalla qué hay que hacer. Las anclas se distinguen por el color y por un símbolo pequeño dentro del sprite de 48 px (jefe_final_ancla_*.png). Verde (Espadachín) y rojo (Segador) es justo la pareja que peor distingue un daltónico. La línea de abajo (panel_equipo.gd, _escribir_linea) no dice qué anclas quedan.
- **Propuesta:** Que el HUD escuche jefe_final_ataco: con "escudo", sacar «ESCUDO: ROMPE CADA ANCLA CON SU PERSONAJE · CAMBIO SIN ESPERA». Mejor en una segunda línea o justo después de «¡NÚCLEO ARMADO!», porque _avisar() pisa el aviso anterior. Mientras dure el escudo, la línea de abajo dice a quién cambiar («anclas: Mago, Segador»). En ancla_escudo.gd (_draw), dibujar encima de cada ancla una mini cara del personaje que la rompe, para que no dependa solo del color.
- **Assets:** 3 mini-retratos de 24x24 (uno por personaje: Mago, Espadachín y Segador), de 1 fotograma, con contorno de su color y fondo transparente. No sirven los retratos de 64x64 escalados: el comentario de datos_personaje.gd dice que se deforman.
- **Ya apuntado:** bitacora.md, sesión 18, «Siguiente paso» 1: que Adam pruebe jugando «si la jaula y el escudo se entienden». Lo de ponerlo en el HUD y que las anclas no dependan solo del color no está apuntado.

### 7. Ranking y récords coherentes con la dificultad

Impacto **medio** · esfuerzo **pequeño** · assets: **no**

- **Cómo está ahora:** gestor_guardado.gd, _va_antes() (línea 112), ordena las victorias solo por tiempo, sin mirar la dificultad: una victoria en fácil en 16:10 va antes que una en difícil en 16:30, y todas acaban poco después de las 15:00. Los récords (_al_terminar_partida) guardan por separado el máximo de tiempo, de nivel y de eliminados. El de tiempo premia la derrota más larga, al revés que el ranking, que pone delante la victoria más rápida. Y el menú (menu_principal.gd, _texto_record, línea 146) junta esos máximos como «MEJOR PARTIDA», aunque salgan de partidas distintas.
- **Propuesta:** En _va_antes, entre victorias, primero la dificultad más alta (difícil > media > fácil) y luego el tiempo. Las entradas viejas ya traen "dificultad" o se toman por media, así que no se rompe nada. Otra opción: en panel_ranking.gd, una tabla por dificultad que se cambia con izquierda y derecha, como las pestañas de las reglas. En el menú, enseñar como «MEJOR PARTIDA» la primera del ranking (ya ordenada) y aparte las victorias y las partidas jugadas.

### 8. Mando completo: personaje anterior, panel del equipo, cruceta y textos de botones

Impacto **medio** · esfuerzo **pequeño** · assets: **no**

- **Cómo está ahora:** En project.godot, personaje_anterior solo tiene la Q (ningún botón del mando) y mover_* solo el stick izquierdo, sin cruceta. El panel del equipo se abre con la tecla física C (panel_equipo.gd, _unhandled_input, línea 97), sin acción de input. Con mando solo se puede pasar al siguiente (Y), y con el escudo de NÚCLEO CERO a veces hay que dar la vuelta entera. La línea de abajo dice [Q], [E], [R] y [C] aunque se juegue con mando (panel_equipo.gd, _escribir_linea), y la ficha del enemigo solo se abre con click.
- **Propuesta:** En teclas_antiguas.gd (configurar), que ya añade al empezar las teclas que faltan, añadir si no están: LB para personaje_anterior, RB también para cambiar_personaje, la cruceta para mover_* y una acción ver_equipo (C y Back/Select), y que panel_equipo.gd use esa acción. Así no hay que subir EJECUTABLE_MINIMO. Que la línea de abajo cambie las letras por los botones del mando si el último input fue un mando. Actualizar CONTROLES en panel_reglas.gd, el manual y el README.
- **Ya apuntado:** presentacion.md, «8. Qué mejoraríamos», habla de controles remapeables. Es otra cosa: esto es completar el mando que ya hay.

### 9. Vibración del mando

Impacto **medio** · esfuerzo **pequeño** · assets: **no**

- **Cómo está ahora:** No vibra nada en todo el juego: buscar vibration o vibrar en escenas/ y globales/ no da resultados. El enunciado pone la vibración como ejemplo de feedback (requisito 10). El golpe al jugador (controlador_jugador.gd, _al_recibir_dano, línea 34) y los golpes fuertes de Kernel Panic (sacudir, que llama espectaculo_jefe.gd) solo tiñen el sprite y mueven la cámara.
- **Propuesta:** Con un mando conectado (Input.get_connected_joypads() no vacío), llamar a Input.start_joy_vibration con distinta fuerza: suave y corta al recibir daño, fuerte en sacudir (aparición, furia y muerte del jefe), media al lanzar la ulti (ulti_lanzada) y al caer un personaje (personaje_caido). Añadir la casilla «Vibración» en panel_opciones.gd y su valor por defecto en OPCIONES_POR_DEFECTO de gestor_guardado.gd. Comprobar la firma en la API de 4.7.2.

### 10. Consejos durante la primera partida

Impacto **alto** · esfuerzo **medio** · assets: **no**

- **Cómo está ahora:** No hay tutorial. El menú (menu_principal.gd, RESUMEN) da tres líneas y el resto está en REGLAS. En la partida, el HUD solo avisa de élites, jefes, la fase 2 y las evoluciones (hud.gd, _ready). Nadie explica que el personaje se mueve y la herramienta ataca sola, que los fragmentos caducan a los 30 s, que el malware se adapta y hay que cambiar, qué hacer en la jaula del pisotón o que el cofre abre una ruleta. Quien no lea las reglas (el tribunal jugando un par de minutos) se pierde el elemento diferencial.
- **Propuesta:** Un script nuevo, consejos.gd (con preload y sin class_name, como los paneles del HUD), hijo del HUD, que escucha el bus y saca un texto pequeño abajo (sin tapar los avisos grandes de _avisar) una sola vez por partida: al empezar (moverse; la herramienta ataca sola), con el primer fragmento (recogerlo antes de 30 s), con la primera subida de resistencia (cambiar con E/Q), cuando la ulti está lista (R o B), con el primer élite muerto (corazón y cofre), con la primera jaula y con el primer escudo. Una opción «Consejos» en panel_opciones.gd, encendida por defecto y que se apaga sola después de la primera partida completa (con GestorGuardado.cambiar_opcion).

### 11. Resumen de la partida en la pantalla final: daño por herramienta y dónde acabó

Impacto **alto** · esfuerzo **medio** · assets: **no**

- **Cómo está ahora:** pantalla_final.gd (_mostrar) enseña tiempo, nivel, eliminados y dificultad. El diccionario de partida_terminada (raiz_juego.gd, _terminar_partida, línea 90) no trae nada del elemento diferencial: resistencia_malware.gd (registrar_dano) suma el daño de cada herramienta solo durante el ciclo de 20 s y lo borra en _analizar. Tampoco se sabe dónde acabó la partida (fase 1, Kernel Panic, fase 2 o qué forma de NÚCLEO CERO).
- **Propuesta:** Llevar un total por herramienta en resistencia_malware.gd (otro diccionario que no se borra) y la resistencia más alta a la que se llegó. Contar los cambios de personaje y los élites eliminados, y apuntar dónde acabó. Pasarlo todo en claves nuevas de partida_terminada y apuntarlas en el contrato de GEMINI.md. En la pantalla final, una barra por herramienta del color de su personaje (con el retrato que ya existe) y una línea tipo «Cayó contra NÚCLEO CERO (amalgama)». Es lo que enseña al tribunal que cambiar de personaje sirvió. No cambia el equilibrio.

### 12. Opciones de accesibilidad: sacudida de cámara y texto más grande

Impacto **medio** · esfuerzo **pequeño** · assets: **no**

- **Cómo está ahora:** Las opciones (panel_opciones.gd, _ready) son música, efectos, pantalla completa, filtro CRT y avisos de versión. La sacudida de cámara al recibir daño (controlador_jugador.gd, _al_recibir_dano, sacudida_camara = 6, con la horda encima en casi cada golpe) y la de sacudir() no se pueden quitar. El texto del HUD tiene tamaño fijo y en sitios es de 11 a 13 px (panel_equipo.gd, ficha_enemigo.gd, panel_experiencia.gd), que en un proyector de clase cuesta leer. Todos los textos salen de EstiloInterfaz.etiqueta (estilo_interfaz.gd, línea 84), y la fuente es una SystemFont (tema()).
- **Propuesta:** Dos casillas nuevas con sus valores por defecto en gestor_guardado.gd. «Sacudida de cámara»: si está apagada, la cámara no se mueve en _al_recibir_dano ni en sacudir. «Texto grande»: EstiloInterfaz.etiqueta multiplica el tamaño por 1,25 cuando está activa; es un solo sitio y vale para todas las pantallas al volver a abrirlas. Aprovechar para mirar en la versión web que la SystemFont sale monoespaciada; si no, meter una fuente libre en el proyecto.

### 13. Menú de pausa: botón de REGLAS y confirmar antes de abandonar

Impacto **bajo** · esfuerzo **pequeño** · assets: **no**

- **Cómo está ahora:** menu_pausa.gd tiene CONTINUAR, OPCIONES y MENÚ PRINCIPAL. Para mirar qué hace un afijo, una mejora o el escudo en plena partida hay que salir: las reglas solo están en el menú principal. Y MENÚ PRINCIPAL (_ir_al_menu, línea 75) sale sin preguntar y la partida se pierde.
- **Propuesta:** Añadir un botón REGLAS que abra un PanelReglas (ya tiene class_name y process_mode ALWAYS, así que funciona en pausa), igual que se hace con PanelOpciones en el mismo script, y que con los cuatro paneles se cierre bien con Esc. Al pulsar MENÚ PRINCIPAL, preguntar «¿Abandonar la partida? No contará para los récords» con SÍ y NO.

### 14. Fase 2 con un enemigo propio (el Popup de la lista de assets)

Impacto **medio** · esfuerzo **medio** · assets: **sí**

- **Cómo está ahora:** En la fase 2 salen los mismos cinco tipos de horda al ritmo máximo (director_oleadas.gd, _elegir_tipo, línea 139) y los élites con dos afijos. Lo único que cambia es el suelo (arena.gd) y la música, más grave (gestor_audio.gd). Añadir un tipo de horda es casi solo datos: un .tres de DatosTipoEnemigo y un nodo GestorEnemigos en raiz_juego.tscn, como los cinco que hay. Ojo: Kernel Panic (jefe.gd, _invocar, línea 263) invoca de todos los gestores sin límite de vivos y no mira tiempo_aparicion.
- **Propuesta:** Un Popup, que es un enjambre muy rápido y frágil, con tiempo_aparicion = 600. Así solo sale en la fase 2: en la 1, al llegar a las 10:00 llega el jefe y deja de salir horda. Filtrar en _invocar los tipos que aún no han aparecido para que Kernel Panic no lo saque antes, y añadirlo a ENEMIGOS en panel_reglas.gd. Cambia el equilibrio, que ahora está en el objetivo: volver a pasar el simulador en las tres dificultades. Solo si Adam quiere más contenido.
- **Assets:** Una tira horizontal de 4 fotogramas cuadrados de 20x20 (como las de recursos/enemigos/sprites/*_anim.png) cuyo fotograma 0 sea también el sprite suelto (textura en su .tres, que sale en la ficha y en las reglas). Algo como una ventana emergente con su barra de título que parpadea, en el estilo neón del resto, y un color propio para el efecto de su muerte.
- **Ya apuntado:** documentacio/assets.md (fichero de Alan), «Por orden de prioridad si hay margen», punto 2: Gusano y Popup como tipos de horda nuevos. No figura en requisitos_y_estado.md.

