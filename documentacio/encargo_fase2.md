# Encargo: fase 2, jefe final NÚCLEO CERO y arreglos del menú F1

Pedido por Adam el 15/10/2026, al final de la clase. Lo pide él, aunque
CLAUDE.md diga que no se añada contenido. **No hay nada programado**: Claude
propuso el plan de abajo y está **pendiente del sí de Adam** (y de sus
respuestas a las preguntas del final). Al terminarlo, este fichero se borra y
lo que se decida pasa a la bitácora, a `requisitos_y_estado.md` y a la
documentación.

## Los dibujos (no están en el repo)

Vienen en `jefe_final.zip`, que Adam hizo con Claude en el chat (está en el
chat y en Descargas del ordenador del instituto, y desde el 16/10 también en
el de casa). En la sesión del 15/10 no se
copiaron al proyecto porque aún no tocaba empezar.

Antes de programar: **descomprimir el zip en la raíz del clon**, encima de lo
que hay. Trae:

- `projecte/medios/texturas/suelo_danado*.png` (3) y
  `projecte/escenas/arena/suelo_danado.tres`
- `projecte/medios/sprites/jefe_final/` (15 PNG)
- `referencia/suelo.gdshader.diff` (el cambio probado del shader del suelo) y
  `referencia/demo_jefe_final.gd` (cómo se dibuja cada sprite; no es la lógica
  del juego)
- vistas previas en la raíz (`jefe_final_en_juego.gif`,
  `suelo_danado_en_juego.gif`, `jefe_final_formas.gif`, `vista_*.png`),
  `herramienta/` (los scripts de Python que lo generan), `LEEME.txt` y
  `PROMPT_CLAUDE_CODE.md` (el encargo, copiado abajo)

Se commitea solo lo de `projecte/`. `referencia/`, `herramienta/`, las vistas
previas, `LEEME.txt` y `PROMPT_CLAUDE_CODE.md` no se commitean.

## Arreglos del menú de desarrollador (F1)

Lo que vio Adam al probar el 15/10:

1. Saltando al minuto 10 se llega a nivel 12, y jugando él va por el 14 en el
   minuto 5: el jefe se prueba con un jugador mucho más débil de lo normal.
2. Al saltar a un minuto te da mejoras, pero si vuelves al minuto 0 te las
   quedas. El menú tiene que ser consistente: cada salto, el mismo resultado.

Causa del 1: las tablas de `progreso_por_minuto.gd` salen del bot del
simulador, y el bot solo va a por el corazón y el cofre de los élites, no a
por los fragmentos de datos: muchos caducan en el suelo. Una persona sí va a
por ellos.

Plan:

- **Bot:** que vaya a por el fragmento más cercano cuando no hay peligro, como
  ya hace con el corazón. Volver a medir las tablas, hasta el minuto 15, y
  contrastarlas con una partida de Adam (su nivel en los minutos 5, 10 y 15,
  mirando F3). Ojo: con un bot más fuerte cambian las victorias del
  simulador, así que lo de la dificultad media se decide después de esto.
- **Hecho el 15/10 (19:00), probado en headless: saltar = empezar de nuevo y
  ponerse en ese minuto.** Se recarga la escena
  de la partida y el salto pendiente se apunta en el árbol
  (`get_tree().root.set_meta(...)`), que sigue ahí al cambiar de escena. Así
  volver al 0 deja la partida como al empezar (sin mejoras, sin resistencias,
  sin horda ni élites) y saltar hacia delante da siempre lo mismo. La partida
  sigue marcada con trucos.
- **Botones nuevos:** IR A LA FASE 2, JEFE FINAL YA (15:00) y SIGUIENTE
  FORMA.
- Ficheros: `panel_trucos.gd`, `progreso_por_minuto.gd` y
  `herramientas/simular_partidas.gd`.

## Plan de la fase 2 (propuesto, sin aprobar)

Una frase sobre subagentes, como pide CLAUDE.md: no compensa repartirlo, casi
todo cuelga de `raiz_juego.tscn`, del bus y del director, y cada bloque
depende del anterior.

### Señales nuevas del bus

- `transicion_fase(segundos: float)`: empieza el negro, con el juego ya en
  pausa. La pantalla de la transición dura esos segundos.
- `fase_cambiada(fase: int)`: detrás del negro. La arena cambia el suelo, el
  audio la música y el HUD avisa.
- `jefe_final_aparecio`
- `jefe_final_vida_cambiada(actual: float, maxima: float)`: para la barra
  del HUD.
- `jefe_final_forma_cambiada(forma: int)`: avisos del HUD y sonido.
- `jefe_final_ataco(ataque: String)`: para que el audio ponga el sonido de
  cada ataque (los de las ultis que ya hay).

`tiempo_partida(segundos, duracion)` no cambia: en la fase 2, `duracion`
pasa a ser 15:00 (cuándo llega el siguiente jefe), y el reloj y la cuenta
atrás del HUD funcionan solos.

### Ficheros nuevos

Todos con `preload` y sin `class_name`, y sin tocar `project.godot`: no hace
falta subir `EJECUTABLE_MINIMO`.

- `escenas/jugabilidad/enemigos/jefe_final.gd` y `jefe_final.tscn`:
  - estados, formas y vida
  - daño recibido según la forma
  - movimiento flotante y destello
  - transformación y muerte
  - lo de `objetivos`: `danar_en_area`, `mas_cercano`, `ficha_en` y `ficha`
- `escenas/jugabilidad/enemigos/ataques_jefe_final.gd`:
  - rayo, torbellino, tormenta, invocación con portales y zonas congeladas
  - elige el siguiente sin repetir; primero el aviso y después el daño
- `escenas/jugabilidad/enemigos/escudo_jefe_final.gd`: la burbuja, las 4
  anclas con sus cadenas, la rotura y el aturdido.
- `escenas/jugabilidad/enemigos/ancla_escudo.gd` y `.tscn`: un ancla, que es
  un objetivo con su vida.
- `escenas/jugabilidad/enemigos/dibujo_jefe_final.gd`: funciones estáticas
  de dibujo, como `dibujo_ultis.gd`.
- `escenas/jugabilidad/efectos/zonas_hielo.gd`: el hielo, debajo del jugador
  (como `Explosiones`), que llama a `ralentizar()` mientras lo pisas.
- `escenas/interfaz/pantalla_fase.gd`: el negro con «SECTOR CERO DAÑADO»
  escrito letra a letra con un poco de glitch.
- `escenas/interfaz/barra_jefe_final.gd`: el marco y el relleno, arriba en el
  centro.

### Ficheros que se tocan

- `globales/bus_eventos.gd` (las señales) y `GEMINI.md` (su lista).
- `escenas/arena/suelo.gdshader` (el diff: chispazos, humo y
  `velocidad_brillo`) y `arena.gd` (con `fase_cambiada`, una copia de
  `suelo_danado.tres`).
- `escenas/jugabilidad/raiz_juego.gd` y `.tscn`:
  - el jefe 1 ya no da la victoria, sino la transición: pausa, negro, quitar
    la horda, el premio de vida y reanudar
  - nodos `JefeFinal` y `ZonasHielo`
  - el menú de pausa no se abre durante el negro
- `oleadas/director_oleadas.gd`:
  - la fase 2: el reloj sigue y a las 15:00 llega el jefe final
  - `saltar_a` sabe de fases
- `datos_config_oleada.gd` y `config_principal.tres`: `duracion_fase_2 = 300`.
- `gestor_enemigos.gd`: `vaciar()`, para quitar la horda de golpe sin dar
  experiencia. La huida no sirve, porque con el juego en pausa no avanza.
- `jefe.gd`: en su ficha pasa a llamarse «Jefe» (el final es NÚCLEO CERO).
- `jugador/dibujo_ultis.gd`: un parámetro de `tormenta` para no dibujar el
  rayo grande.
- `hud.gd` y `hud.tscn`:
  - la barra del jefe final
  - los avisos: ¡FASE 2!, ¡NÚCLEO CERO!, ¡NÚCLEO ARMADO! y ¡AMALGAMA!
- `globales/gestor_audio.gd`:
  - fase 2: la música de la partida más grave (`pitch_scale`)
  - jefe final: la del jefe, algo más rápida
  - sonidos: los que ya hay
- `pantalla_final.gd` (el texto de la victoria), `panel_reglas.gd` (el
  objetivo y las fichas de los jefes) y, según lo que se decida del ranking,
  `gestor_guardado.gd`.

### El diff del shader, revisado

Ningún número tiene un cero justo detrás del punto (`1.0 / 10.0` en vez de
`0.1`). El chispazo (azul = 40/255 ≈ 0,16) va en un `else if` después del
brillo de los chips (azul > 0,2), así que no se pisan. Con `humo = 0` y los
valores por defecto, el suelo normal debería dibujarse igual que ahora: falta
comprobarlo con ventana y una captura del antes y el después.

### Orden de trabajo (un commit por bloque)

1. Arreglos del F1 y bot que recoge fragmentos (sirven para probar lo demás).
2. `assets` del suelo dañado y `assets` del jefe final.
3. El shader y el suelo de la fase 2.
4. El paso a la fase 2.
5. El jefe final: formas, movimiento, transformación y muerte.
6. Los ataques; después el escudo con sus anclas y el hielo.
7. La barra del HUD.
8. El simulador.
9. La documentación.

### Preguntas para Adam (contestadas el 16/10)

1. **Premio por el jefe 1:** **no cura.**
2. **Ranking:** pone primero las victorias más rápidas, y las de ahora (unos
   11 minutos) quedarían siempre delante de las nuevas (más de 15). **Se
   vacían el ranking y los récords una vez**, al llegar a esta versión.
3. **Nombre del jefe 1:** **«JEFE» a secas**, de momento.
4. **Victorias por dificultad:** **el balance se hace al final**, con el
   juego terminado. Hasta entonces, los números del encargo.

## El encargo, tal como lo pasó Adam

Hoy toca algo grande: una **fase 2** con el mapa destrozado y un **jefe final nuevo en el minuto 15**, con unos dibujos que he hecho fuera (con Claude en el chat). Sigue el CLAUDE.md como siempre: lee la bitácora y el estado antes de empezar, valida en headless y no hagas push hasta que te diga "ya he acabado". Esto lo pido yo, aunque el CLAUDE.md diga que no se añada contenido.

Es mucho trabajo. **Antes de programar, dame un plan corto** con los ficheros que vas a crear y los que vas a tocar, y las señales nuevas del bus. Espera a que te diga que sí. Si algo de lo de abajo no está claro o choca con una decisión vigente, pregúntame.

He descomprimido `jefe_final.zip` en la raíz del repo. Mira con `git status` qué ha llegado. En la raíz hay vistas previas grabadas en Godot 4.7.2 con estos mismos ficheros: míralas, sobre todo `jefe_final_en_juego.gif`, `suelo_danado_en_juego.gif` y `jefe_final_formas.gif`.

### 1. Cómo queda la partida

- **Fase 1 (0:00 a 10:00):** como ahora. A los 10:00 llega el jefe de siempre.
- **Al matarlo ya no se gana.** Empieza la transición a la fase 2:
  1. La pantalla se va a negro y se queda así unos **3 segundos**, con un texto corto en medio, por ejemplo "SECTOR CERO DAÑADO". Si queda bien, que se escriba letra a letra o con un poco de glitch. Mientras dura, el juego está parado y el menú de pausa no se abre.
  2. Detrás del negro, el suelo pasa al **suelo dañado**: `arena.gd` cambia el material de `Suelo` por una copia de `escenas/arena/suelo_danado.tres`. También desaparece la horda que quedaba (sin dar experiencia, como en la huida). Propónme si el jugador recupera algo de vida como premio por el jefe.
  3. Vuelve la imagen. La horda sigue apareciendo y el reloj sigue desde 10:00.
- **Fase 2 (10:00 a 15:00):** horda y élites como hasta ahora, un poco más duros. A los 15:00 deja de salir horda y llega el **jefe final**, con la misma regla de dificultad de siempre (en fácil, la horda que queda huye).
- **Se gana al matar al jefe final**, después de su animación de muerte. Si caes en la fase 2 es derrota, con el tiempo que llevabas.
- El reloj del HUD llega hasta 15:00, con la cuenta atrás del jefe final.
- La duración de la fase 2 va en `config_principal.tres`, no escrita en el código.
- Comprueba que los récords, el ranking y la pantalla final siguen teniendo sentido con partidas de más de 10 minutos.
- En el menú de desarrollador (F1): "ir a la fase 2", "jefe final ya" y "siguiente forma del jefe final".

### 2. Suelo dañado

Ficheros:

- `medios/texturas/suelo_danado.png`, `suelo_danado_mascara.png` y `suelo_danado_efectos.png`. Son las mismas 12 baldosas de 256x256, así que encajan igual, pero destrozadas: placa quemada, grietas al rojo, pistas cortadas (los pulsos se cortan en ellas), chips partidos o reventados, condensadores hinchados, cráteres con brasas, restos y chispazos.
- `escenas/arena/suelo_danado.tres`: el mismo shader con esas texturas y los colores de la fase 2 (pulsos rojos, brasas naranjas, LEDs que fallan, ventilador lento, chispazos y humo).

`referencia/suelo.gdshader.diff` es el cambio probado de `suelo.gdshader`. Añade tres cosas, y **con los valores por defecto el suelo normal se queda exactamente igual**:

- **Chispazos:** un efecto nuevo con azul = 40/255. Cada chispazo salta un rato de cada ciclo, con un arco eléctrico de 3 fotogramas y un resplandor.
- **Humo:** sombras que cruzan el suelo despacio, en tres escalones de oscuridad. Es ruido calculado con la posición en el mundo.
- **`velocidad_brillo`:** las brasas respiran más deprisa que el brillo de los chips.

Está escrito sin números con un cero detrás del punto. Revisa que lo entiendo, porque lo tengo que defender. Comprueba el shader con ventana y haz una captura, como dice CLAUDE.md.

### 3. Jefe final: NÚCLEO CERO

Junta todo el juego. Va cambiando de forma según pierde vida, y en cada forma **cuesta más matarlo**: recibe menos daño y ataca más deprisa.

`medios/sprites/jefe_final/jefe_final.png` tiene 6 columnas x 3 filas de 192x192. Cada fila es una forma y las 6 columnas son su animación de reposo:

| Fila | Forma | Vida | Fotogramas por segundo | Qué lleva |
|---|---|---|---|---|
| 0 | Rootkit gigante | 100-66 % | 8 | el rootkit de los élites en grande, con conectores, "#>_" y fragmentos dorados en órbita |
| 1 | Núcleo armado | 66-33 % | 10 | agrietado, con la corona y la capa del primer jefe, el bastón del Mago, la espada del Espadachín y la hoja de la guadaña del Segador detrás |
| 2 | Amalgama | 33-0 % | 12 | además: el ransomware de pecho, troyanos de hombreras, alas de paquete perdido, pinchos de bit corrupto, carámbanos y ojos de "cargando" del proceso colgado, y bits y paquetes dando vueltas |

- Flota: no anda en 8 direcciones ni se voltea. Se acerca al jugador despacio y guarda las distancias. Lleva una sombra dibujada en el sprite.
- Valores de partida para ajustar con el simulador:
  - **Vida:** unas 3 veces la del primer jefe, con el multiplicador de dificultad.
  - **Daño recibido:** 100 % en la forma 1, 75 % en la 2 y 60 % en la 3.
  - **Pausa entre ataques:** 2,5 s, 1,8 s y 1,2 s.
  - **Velocidad:** 60, 75 y 90.
- **Cambio de forma:** al cruzar el 66 % y el 33 % de vida.
  - Se corta el ataque en curso y es invulnerable durante `jefe_final_transformacion.png` (8 fotogramas de 256x256, 0,1 s cada uno, centrado en el jefe).
  - En el fotograma 4 se cambia de fila en la hoja.
  - Temblor de pantalla y sonido.
- **Muerte:** se esconde el sprite y se reproduce `jefe_final_muerte.png` (12 fotogramas de 320x320, 0,08 s cada uno; ya incluye al jefe rompiéndose). Al acabar, la victoria.
- Como el jefe de siempre, va en el grupo `objetivos`, con `danar_en_area`, `mas_cercano`, `ficha_en` y `ficha`.
- Si ya está hecho el destello al recibir golpes del prompt de la horda, que lo tenga también.
- **Barra de vida en el HUD:** `jefe_final_barra.png` (480x40, con el nombre y las marcas al 66 % y al 33 %) arriba en el centro. Encima, `jefe_final_barra_relleno.png` (448x10) en (16, 20), recortado según la vida. La interfaz se entera por señales del bus, no mirando al nodo.

### 4. Ataques

Cada forma tiene su lista de ataques. El siguiente se elige al azar entre los de la forma, sin repetir el mismo dos veces seguidas. Todos avisan antes de hacer daño, así que se pueden esquivar. Las ultis las ha "robado" a los personajes, así que **se dibujan con las mismas funciones de `dibujo_ultis.gd`**.

| Ataque | Formas | Cómo va | Sprites |
|---|---|---|---|
| **Rayo de datos** (Mago) | 1, 2, 3 | Aviso de 0,8 s: una línea hacia donde está el jugador en ese momento. Después, el rayo de la ulti (0,6 s, radio 34). En la forma 3, dos rayos a ±25°. | `jefe_final_aviso_linea.png` (4 x 32x24, se repite cada 32 px a lo largo del rayo, 0,08 s por fotograma) y `Dibujo.rayo` |
| **Torbellino** (Espadachín) | 2, 3 | Aviso de 0,8 s con el anillo de 170 px alrededor del jefe. Después, el torbellino de la ulti durante 1,5 s, con daño mientras estés dentro. | `jefe_final_aviso_zona.png` (4 x 352x352) y `Dibujo.torbellino` |
| **Tormenta** (Segador) | 1, 2, 3 | 3, 5 u 8 dianas (según la forma) alrededor del jugador durante 0,6 s y después los mini rayos de la ulti, cada uno en su diana (radio 60). | `jefe_final_aviso_diana.png` (4 x 64x64, 0,15 s) y los mini rayos de `Dibujo.tormenta`. Añádele un parámetro para que no caiga el rayo grande, en vez de adelantar el tiempo. |
| **Invocar** | 1, 2, 3 | 2 o 3 portales cerca del jefe. Mientras están abiertos sale horda por ellos con el `aparecer` de los gestores. Desde la forma 2, además un rootkit élite explosivo si hay uno libre. | `jefe_final_portal.png` (8 x 96x96: se abre en 0-2, gira en 3-5 y se cierra en 6-7) |
| **Escudo de candado** (ransomware) | al entrar en la 2 y en la 3 (en la 3, también cada ~35 s) | El jefe se encierra en una burbuja y no recibe daño. Salen 4 anclas a unos 240 px, unidas al jefe con cadenas. Las anclas son objetivos con su vida. Cada una que rompes muestra su fotograma roto y pierde su cadena. Al romper las 4, la burbuja estalla y el jefe se queda aturdido 2 s, recibiendo un 50 % más de daño. | `jefe_final_escudo.png` (4 x 240x240), `jefe_final_escudo_rotura.png` (6 x 256x256, 0,1 s), `jefe_final_ancla.png` (5 x 48x56: 0-3 brillando, 4 rota) y `jefe_final_cadena.png` (2 x 16x10, se repite a lo largo) |
| **Zonas congeladas** (proceso colgado) | 2, 3 | Lanza 2 o 4 cristales hacia puntos cerca del jugador (vuelan 0,45 s). Donde caen se forma una zona de hielo de unos 60 px de radio durante 6 s. Dentro, el jugador va un 40 % más lento: hay que reutilizar `ralentizar()`, como el aura lenta. | `jefe_final_proyectil_hielo.png` (4 x 24x24) y `jefe_final_hielo.png` (8 x 160x160: se forma en 0-3 a 0,08 s y luego repite 4-7) |

Por dónde lo haría (decide tú lo más fácil de defender):

- Repartirlo en varios scripts:
  - el jefe: estados, formas, vida y movimiento
  - los ataques
  - un `dibujo_jefe_final.gd` con funciones estáticas, como `dibujo_ultis.gd`
  - una escena pequeña para las anclas
- Todo con `preload` y sin `class_name`, para no tener que subir `EJECUTABLE_MINIMO`. Si se puede, no toques `project.godot`.
- Las zonas de hielo, debajo del jugador y de la horda (como el suelo). Los avisos y los ataques, por encima.
- `referencia/demo_jefe_final.gd` es la demo con la que se ha grabado `jefe_final_en_juego.gif`. **No es la lógica del juego:** es un recorrido con el tiempo controlado, pero enseña cómo se dibuja cada sprite (anclas, tamaños, fotogramas y tiempos).
- Señales nuevas en el bus. Por ejemplo, `fase_cambiada(fase)`, `jefe_final_aparecio`, `jefe_final_vida_cambiada(actual, maxima)` y `jefe_final_forma_cambiada(forma)`. Las escuchan la arena, el HUD (barra y avisos como "¡NÚCLEO ARMADO!") y el audio. Apúntalas en GEMINI.md.
- Sonidos con lo que ya hay en `GestorAudio`. Si la música de la fase 2 puede ir algo más rápida o más grave sin complicarse, bien.

### 5. Al terminar

- **Validación completa del CLAUDE.md:** import, `--quit-after` e instrumentación temporal. Pasa por todo:
  - la muerte del jefe 1 y la transición
  - el suelo nuevo
  - la llegada del jefe final y sus tres formas
  - cada ataque, el escudo con sus anclas y el hielo que ralentiza
  - la muerte del jefe final y la victoria
  - también una derrota en la fase 2

  Borra la instrumentación al acabar.
- **Capturas con ventana** (hay shaders): el negro de la transición, el suelo dañado, cada forma, cada ataque, el escudo con sus anclas y la muerte.
- **Simulador:** el bot tiene que llegar a la fase 2 y pelear con el jefe final. Que vaya a por las anclas cuando hay escudo y que se aparte del hielo si es fácil de programar. Pasa 10 partidas por dificultad, dame las victorias y dónde muere el bot, y propónme ajustes. Antes de cambiar los números, pregúntame cuántas victorias queremos en cada dificultad.
- **Rendimiento:** mídelo en casa con `herramientas/medir_rendimiento.gd`, con el suelo dañado y el jefe final en pantalla.
- **Documentación:**
  - GEMINI.md: el "Qué es" (ya no son 10 minutos más un jefe), las señales y lo del arte.
  - `creditos.md`: el suelo dañado y todo el jefe final son de Claude, con IA, como los demás sprites.
  - `documentacion_tecnica.md`, `manual_usuario.md` y el panel de reglas.
  - La bitácora, `requisitos_y_estado.md` y `planificacion.md`.
- La carpeta `referencia/` no se commitea.
- **Commits pequeños** con la convención de `documentacio/flujo_de_trabajo.md`, uno por bloque. Por ejemplo:
  - `assets` del suelo dañado
  - `assets` del jefe final
  - `feat` del shader y el suelo de la fase 2
  - `feat` del paso a la fase 2
  - `feat` del jefe final
  - `feat` de los ataques
  - `feat` de la barra del HUD
  - `chore` del simulador
  - `docs`
