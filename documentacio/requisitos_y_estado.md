# Requisitos del enunciado y estado del proyecto

Resumen en castellano de lo que pide el profesor, contrastado con lo que hay hecho.
El texto original, que es la fuente de verdad, está en `enunciat.md`; la plantilla
del primer informe, en `primer_seguiment.md`.

**Estado verificado el 29/10/2026** contra la bitácora (hasta la sesión 19) y
contra el código del repositorio. Se actualiza al cerrar cada sesión, junto con
la bitácora y las casillas de `planificacion.md`.

## Qué es esto, en tres líneas

Proyecto 1 de "Demostra el teu talent": hay que crear una experiencia interactiva
en Unity o Godot que convenza a un tribunal que hace de grupo de inversores. Se
valora más un proyecto **pequeño, coherente y pulido** que uno ambicioso e
incompleto, y hay que **saber explicar y modificar cualquier línea** del código
(la IA está permitida, pero no excusa no entender lo entregado). Nuestro proyecto
es **Sector Cero**, un survivors-like 2D en Godot 4.7.2.

## Fechas

- **Solo cuenta la entrega final** (lo aclaró Adam el 15/10). Las entregas de
  antes (la del 2 de octubre, con la propuesta y el informe del primer
  seguimiento) eran subir el enlace del GitHub para que los profesores vieran
  cómo iba el proyecto en esas fechas.
- Entrega final y defensa: la fecha no consta en el enunciado ni en el repositorio.
  Preguntar a Adam si hace falta.

## Requisitos mínimos (los 13 del enunciado)

| # | Requisito | Estado | Detalle |
|---|---|---|---|
| 1 | Pantalla inicial | Hecho | Menú con reglas, controles, récord y opciones (`escenas/menu_principal/`) |
| 2 | Al menos dos escenas o estados | Hecho | Menú, partida, pausa, opciones, subida de nivel y resultados |
| 3 | Mecánica principal funcional | Hecho | Esquivar mientras la herramienta ataca sola; cinco tipos de horda (uno embiste), élites, jefe, fase 2 con el mapa dañado y jefe final de tres formas (NÚCLEO CERO), experiencia, ocho mejoras y evoluciones |
| 4 | Interfaz (UI/HUD) | Hecho | HUD con vida, nivel, experiencia, reloj, cuenta atrás del jefe y del jefe final, barra de vida del jefe final, mejoras, personaje activo y avisos; panel del equipo (C), ruleta del cofre y ventana para elegir quién sigue al caer un personaje |
| 5 | Controles coherentes | Hecho | Teclado, ratón en los menús y mando. Explicados en el menú, el manual y el README |
| 6 | Pausa o menú equivalente | Hecho | Menú de pausa con opciones, y pausa automática al subir de nivel |
| 7 | Persistencia | Hecho | `globales/gestor_guardado.gd`: récords (tiempo, nivel, eliminados, partidas, victorias), ranking de las 10 mejores partidas con nombre y opciones en `user://sector_cero.cfg` |
| 8 | Audio (música o ambiente y al menos 3 efectos) | Hecho | 3 músicas (menú, partida, jefe) y 17 efectos, sintetizados con `herramientas/generar_audio.gd` |
| 9 | Animaciones o transiciones | Hecho | Fundidos entre escenas, personajes en 8 direcciones (las piernas al ritmo de la velocidad), horda animada con una tira de fotogramas por tipo en el shader, glitch de la horda, destello de élites y jefe al recibir golpes, explosión del rootkit (aviso, explosión y quemadura), caída y derrota del personaje, muerte de los élites, círculo de la invocación de Kernel Panic, Ping y fragmentos animados, transición a negro de la fase 2, jefe final (tres formas, transformación, muerte, ataques, escudo y hielo), suelo animado (pulsos, LEDs, ventiladores; en la fase 2, chispazos y humo), barra de experiencia que se llena y destella, tweens en menús y avisos |
| 10 | Feedback en las acciones importantes | Hecho | Números de daño, partículas, destello del enemigo golpeado, golpe, escudo y evolución sobre el personaje, destello al recoger experiencia, parpadeo del troyano antes de embestir, tinte y sacudida de cámara, sonidos y avisos |
| 11 | Código estructurado | Hecho | Bus de eventos, recursos `.tres`, una responsabilidad por script. Los más largos pasan de las ~200 líneas orientativas, contando comentarios: `gestor_enemigos.gd` (388; la embestida y el volteo van aparte), `jefe_final.gd` (302; los ataques, el escudo, las anclas, el hielo y el dibujo van en sus scripts) y `ataques_jefe_final.gd` (257); se ha quitado el código muerto |
| 12 | Git con evolución real | Hecho | Más de 80 commits progresivos con la convención `tipo(ámbito)` |
| 13 | Build ejecutable sin abrir el editor | Casi | Releases v0.2 a v1.12 publicadas por la GitHub Action (desde la v1.5, con el lanzador y su instalador; desde la v1.8, solo con el lanzador), también en la web; las anteriores se republicaron el 14 y el 15/10 con el menú VERSIONES (INSTALAR descarga sin cambiar de versión; CAMBIAR pasa a ella). Desde el juego se actualiza y se cambia a cualquier versión. Falta probarlas en un ordenador limpio |

## Factor diferencial (al menos uno)

- **Hecho:** resistencia adaptativa del malware. Cada 20 s el malware gana un 10 %
  de resistencia (máximo 50 %) a la herramienta que más daño le hizo y pierde un
  5 % contra las demás. La respuesta es cambiar de personaje o elegir la mejora
  Actualizar firmas, que frena la adaptación.
- **Hecho:** élites con afijos procedurales (blindado, replicante, aura lenta y
  explosivo).
- **Hecho:** shaders propios (suelo de placa base animado, glitch y aviso de la
  horda, CRT) y audio sintetizado.

## Entregables (los 7 del enunciado)

| # | Entregable | Estado | Qué falta |
|---|---|---|---|
| 1 | Repositorio Git con historial | Hecho | Seguir subiendo al cerrar cada sesión |
| 2 | Build ejecutable | Casi | v1.12 publicada el 29/10, también en la web, con el lanzador y su instalador. Falta probarla en un ordenador limpio |
| 3 | `README.md` | Hecho | Portada para el profesor (la entrega es el enlace de GitHub): qué es, cómo jugar, capturas, resumen de la evolución, autores y uso de la IA. Lo de Git pasó a `flujo_de_trabajo.md` |
| 4 | Documentación técnica (3-5 págs.) | Hecho | `documentacion_tecnica.md`, reescrita el 02/10 en unas 2100 palabras. La evolución desde cero, con capturas reales de cada versión, está en `historia_del_proyecto.md` |
| 5 | Manual de usuario (1 pág.) | Hecho | `manual_usuario.md`, reducido a una página |
| 6 | Vídeo demostrativo (2-4 min) | **Pendiente** | Adam quiere que se le recuerde más adelante. Opción propuesta: grabarlo con el Movie Maker de Godot y un guion automático |
| 7 | Presentación y defensa | En curso | Guion y preguntas probables en `presentacion.md`. Falta ensayar |

Créditos de los assets: `creditos.md`. El audio y parte de los iconos son
propios, generados por código. Con IA: los sprites de los personajes y del jefe
(Gemini y Claude, a partir de un ejemplo del profesor) y, desde el 02/10, los
de la horda y el élite, tres iconos y el suelo (Claude). Nada de terceros.

## Criterios de evaluación (100 puntos)

| Apartado | Puntos | Dónde estamos |
|---|---|---|
| Funcionamiento y MVP | 25 | MVP completo, más las ampliaciones y el contenido del 02/10 |
| Programación, arquitectura y calidad del código | 20 | Buena base. Hay que poder defender cada línea (`presentacion.md`) |
| Experiencia de usuario, UI y pulido | 15 | Interfaz completa, opciones, transiciones, partículas, CRT y audio |
| Elemento diferencial y creatividad | 15 | Resistencia adaptativa, cambio de personaje, élites con afijos |
| Robustez, testing y rendimiento | 10 | Pruebas en headless, simulador de partidas y rendimiento medido en GPU real |
| Documentación y capacidad de explicar | 10 | README, documentación técnica, manual, créditos y bitácora |
| Git, proceso y entrega | 5 | Historial progresivo. Falta la entrega final |

## Qué tiene que contar la presentación

Idea original; qué se ha construido; mecánica principal; decisiones técnicas;
**el problema técnico más difícil**; qué diferencia al proyecto; qué se mejoraría
con más tiempo; y una **demostración** en vivo. El tribunal puede preguntar por
cualquier fragmento del código. Todo está preparado en `presentacion.md`.

## Lo que queda por hacer, en orden de prioridad

Puesto al día el 27/10, al cerrar la sesión 18 (36 h de 60), y el 29/10 con lo
de la nube (sus horas, sin apuntar). Lo hecho está en la bitácora, en la sesión
que se indica; aquí solo queda lo que falta y lo necesario para hacerlo.

**Publicado:** la última es la **v1.12** (29/10: los jefes más duros, y lo de la nube del 26 al 29/10: el lote 9 de la interfaz, el lote 10, el sonido nuevo y el tajo corriendo; novedades en `documentacio/novedades/v1.12.txt`). Antes, la **v1.11** (27/10: movimiento fluido, atacar
corriendo y el bastón del Mago; antes, la v1.10 del 24/10): instaladores de Windows y
de Linux, los `.pck` que usa el lanzador y `version.json`, sin el juego
suelto (decisión de Adam, sesión 18), y la web. Lleva NÚCLEO CERO a 0,5 en
media (100 partidas por dificultad: 78 / 49 / 13), las mejoras C y F sin
dibujos (bitácora, sesión 18, «En casa, las mejoras C y F»), el lote 8 de
dibujos («En casa, el lote 8») y el tajo del Espadachín al enemigo más
cercano. Novedades en `documentacio/novedades/v1.10.txt`.

**Publicado en la v1.12** (de la nube, del 26 al 29/10, fusionado con
`main` el 29/10; bitácora, sesión 18, desde «La nube, en paralelo»):
- el lote 9 entero: el medidor de la resistencia, los rótulos del final, las
  medallas, la barra del equipo, el HUD de arriba, los avisos con banda, los
  paneles y botones de 9 trozos, las teclas dibujadas, los iconos de las
  reglas, los controles del móvil, los mini retratos, la fuente pixel art en
  los textos grandes y el lanzador (que llega con su `.pck`)
- el lote 10: el reposo de los personajes y las poses de Kernel Panic
- el sonido: el escudo, las ultis, las evoluciones y las músicas nuevas
- el tajo del Espadachín corriendo (hoja de 24 columnas) y su robo de vida a
  la mitad.

El lote 11 ya salió en la v1.11; en la fusión se quedó la versión de la nube,
que es la misma más el reposo y el tajo nuevo. Sin novedades escritas aún
para la próxima versión: escribirlas antes de subir su etiqueta. **Lo de los
jefes (puntos 8 y 9) quedó sin hacer:** Adam lo dejó para casa, porque además
de programarlo hay que medir el equilibrio y probarlo.

**Se publicó sin volver a medir el equilibrio** (Adam lo dejó para más
adelante): el tiempo de golpe y la sacudida cambian un poco las partidas, y
el Espadachín apunta solo (el bot ya apuntaba, así que debería moverse
poco). Falta medirlo con 100 partidas por dificultad (punto 7).

### Para la entrega

1. **Vídeo demostrativo** (2-4 min).
2. **Ensayar la defensa** con `presentacion.md`, que ya tiene el guion y las
   preguntas probables. Repasar que cuente lo nuevo (Kernel Panic, NÚCLEO
   CERO, el lanzador, el equilibrio con el simulador).
3. **Probar en un ordenador limpio** (sin Godot): instalar con
   `SectorCero_Instalador_vX.exe`, abrir varias versiones desde el
   lanzador, jugar y desinstalar. Y lo mismo en un Linux de verdad con
   `SectorCero_Lanzador_linux_vX.zip` (los pasos, en la bitácora, sesión
   16), mirando también el icono: el juego escribe al arrancar
   `~/.local/share/applications/sector-cero.desktop` (`icono_linux.gd`); si
   el dock no lo enseña, mirar que `StartupWMClass` ("Sector Cero")
   coincida con la clase de la ventana (`xprop WM_CLASS` en X11).
4. **Acordar con Alan** qué parte de la entrega asume (vídeo, presentación,
   pruebas).

### Probar jugando (Adam)

El simulador no juzga sensaciones ni sonido. Con la v1.11 (o `main` abierto
en Godot):

- **El Espadachín:** desde el 24/10 el cono va solo al enemigo más cercano;
  si ahora se nota útil. Desde el 27/10, que al atacar corriendo se vea el
  tajo entero, y que el robo de vida (ahora como mucho 0,75 por golpe; 1 con
  la evolución) cure lo justo en las partidas largas.
- **Atacar corriendo** (lote 11): que se note que ataca sin que las piernas
  se paren ni salten al empezar y al acabar, con los tres y con el arma
  evolucionada; y el ataque quieto nuevo del Mago (adelanta el bastón y
  suelta la bola).
- **El medidor de la resistencia** (lote 9): que se lea de un vistazo
  arriba a la derecha, que el color y el latido avisen al subir y que no
  pise nada (con mando, con «Texto grande» y en la web en el móvil). Y los
  rótulos del final y las medallas del ranking.
- **La interfaz nueva** (lote 9): la barra del equipo abajo (se entiende a
  quién pasas, la espera, la ulti), los botones con ratón y con mando (el
  foco se distingue del ratón encima), las opciones, las reglas con la
  tabla de controles y que todo se lea bien sin suavizar; con «Texto
  grande», que nada se salga. En la web desde el móvil, los botones y el
  joystick nuevos. Y el lanzador: la barra al descargar una versión.
- **El reposo y las poses** (lote 10): quietos, que respiren sin saltos al
  pararse; Kernel Panic cargando antes de cada ataque y el pisotón.
- **El sonido nuevo** (27/10, generado en la nube sin poder escucharlo
  jugando): el volumen de cada efecto al lado de los de siempre (sobre todo
  el «tunk» del ancla bloqueada, que puede repetirse mucho, y la tormenta),
  la música de la fase 2 y la de NÚCLEO CERO, y que al morir y ganar el
  acorde final no tape la pantalla final.
- **Las animaciones de ataque** de los tres personajes y las armas
  evolucionadas en el personaje.
- **Kernel Panic** (F1 → JEFE YA): la jaula, la ráfaga, el aviso de la
  embestida, las dos furias (al 66 % y al 33 %) y su muerte antes del negro
  de la fase 2.
- **NÚCLEO CERO** (F1 → JEFE FINAL YA y SIGUIENTE FORMA): cada ataque (que el
  aviso se entienda y se pueda esquivar), el escudo cambiando de personaje
  para cada ancla (sin espera mientras está), el hielo y la victoria.
- **Las tres dificultades:** si se sienten como se quiere al jugarlas una
  persona, no el bot.
- **El aviso de que el malware se adapta** a tu herramienta, y cómo suena
  todo (pisotón, ráfaga, furias, escudo).
- **El lanzador se actualiza solo:** uno instalado con una versión anterior
  tiene que pasar a la v1.11 sin hacer nada.
- **Correr** (en `main`, 24/10): si el personaje ya se ve fluido en la
  pantalla de 239 Hz, y si atacar corriendo (lote 11) y el bastón del Mago se
  ven bien.
- **Los efectos del lote 8:** si la caída antes del panel (0,64 s)
  y la derrota antes de la pantalla final (0,96 s) se sienten bien o se hacen
  largas; si el golpe rojo tapa demasiado al personaje; la mira del Mago y el
  rayo de la ulti lista junto a la barra.
- Lo que nunca se ha probado jugando: la explosión del rootkit (v1.2) y lo
  de la v1.1 (horda animada, destellos, piernas, barra de experiencia).

Ojo al probar: si se cierra el juego a la fuerza (matando el proceso), la
caché de shaders puede quedar a medias y la siguiente vez sale la pantalla en
blanco (pasó en el instituto). Se arregla borrando `shader_cache` en la
carpeta de datos del juego.

### Pendiente técnico

6. **Volver a medir las tablas del F1** (`progreso_por_minuto.gd`, nivel y
   mejoras por minuto): se midieron antes de cambiar las dificultades.
7. **Si se toca algo de los jefes o del equilibrio, volver a pasar el
   simulador**: 20 partidas por dificultad, en el mismo ordenador que la
   medida anterior (en la nube y en casa el mismo código da otros números).
   Objetivo de Adam, de cada 20: **15-16 victorias en fácil, 8-10 en media y
   2 en difícil** (de cada 100: 75-80, 40-50 y unas 10). La última medida, con 100 partidas por dificultad (23/10, en casa), da **78 / 49 / 13**. Con 20, el azar mueve el resultado ±2-3 victorias: para calibrar, 100.

### Opcional (Adam decide si se hace)

8. **Hecho el 29/10 (sesión 19): Kernel Panic, lo que faltaba.** Con menos
   de la mitad de vida encadena tres embestidas (la 2.ª y la 3.ª con un aviso
   de 0,4 s); al bajar de la mitad llama una vez a un rootkit explosivo de
   guardaespaldas. Publicado en la v1.12; falta probarlo jugando.
9. **Hecho el 29/10 (sesión 19): NÚCLEO CERO, lo que faltaba.**
   - vida de 12000 a 18000
   - pausas de 2, 1,4 y 0,9 s
   - el escudo cada 45 s en la forma 2 y cada 25 s en la 3
   - al llegar, portales y tormenta enseguida
   - en la amalgama, dos ataques distintos a la vez (`Ataques2`)

   Con 20 partidas por dificultad (en el instituto): **11 / 7 / 1** (objetivo
   15-16 / 8-10 / 2). Fácil y media perdían por tiempo contra la amalgama:
   su vida bajó en fácil de 0,42 a 0,32 y en media de 0,5 a 0,45, **sin
   volver a medir** (Adam no quiso más simulaciones). Publicado en la v1.12.
   Por la tarde, medida a medias (se cortó al cerrar la VM): fácil 9/11,
   media 3/12, difícil 0/9; media sigue perdiendo contra la amalgama. Falta
   la medida completa (punto 7).
10. **Mejoras propuestas, lo que queda** de `mejoras_propuestas.md` (A, B sin
    dibujos, C entera y F sin dibujos, hechas):
    - **D. Lo visual por código, con assets:** hecha entera. La partida, el
      24/10 (lote 8); la interfaz y el lanzador, el 26 y el 27/10 (lote 9),
      y el reposo y las poses de Kernel Panic, el 27/10 (lote 10).
    - **E. Sonido y música:** lo principal, hecho el 27/10 (el escudo de
      NÚCLEO CERO, las ultis, las evoluciones y las músicas de la fase 2 y
      del jefe final). Queda lo opcional de la lista (avisos de los ataques
      de los jefes, poca vida, recoger cosas, menús, cámara lenta).
    - **F, lo que queda:** el Popup de la fase 2 (dibujo y reequilibrar). Los
      iconos de las reglas se hicieron con el lote 9.
11. **Lo que quedó por decidir de la sesión 17** (bitácora, sesión 17,
    «Siguiente paso», punto 5): `jefe.gd` pasa de las ~200 líneas de la
    guía y se podrían sacar las furias a su script; y lo que eligió Claude en
    el lote 6 (los personajes de las reglas sin retrato, el aviso del HUD del
    élite sin iconos y el lema del lanzador quitado).
12. **Las releases antiguas** (v0.2 a v1.7) siguen teniendo el juego suelto
    (`SectorCero_vX_windows.zip` y `_linux.zip`). Si Adam quiere quitarlos
    también de ellas, se borran a mano desde la web de GitHub (no se puede
    deshacer; el lanzador no los usa).
13. **Para más adelante:**
    - **Ranking mundial** con Supabase (Adam crea el proyecto; Claude le pasa
      el script SQL y los pasos).
    - **Pixel art propio** en lugar de los sprites hechos con IA.
    - **Cooperativo en red local** (idea de Adam, 22/10, sesión 18). Tres
      personas en la misma red, cada una con un personaje, sin cambiar con E
      y Q. Lo que habría que decidir antes, con Adam:
      - **La red:** la multijugador de Godot (`ENetMultiplayerPeer`), con un
        ordenador que hace de anfitrión y lleva la partida (la horda, los
        jefes, el daño) y los otros dos que mandan su movimiento y reciben lo
        que pasa. Buscar la partida en la red local o escribir la IP.
      - **Qué cambia en el juego:** tres jugadores en el grupo `jugador` (hoy
        todo busca uno: la horda, los jefes, la jaula, la cámara); quién
        elige las mejoras y qué pasa con la pausa; la ulti de cada uno; qué
        pasa al caer uno; las anclas del escudo, que ya son una por
        personaje, irían bien.
      - **Lo que cuesta:** es lo más grande que queda; tocaría casi todos
        los sistemas y la escena de la partida. Solo si sobra tiempo después
        de la entrega o como mejora futura en la defensa («qué
        mejoraríamos»).

## Decisiones vigentes (no revertir sin hablarlo con Adam)

El porqué de cada una está en `bitacora.md`, en la sesión que se indica.

- **Sesiones 10 y 11** (decisiones de Adam): gemas amarillas, naranjas y
  magentas; la horda huye al llegar el jefe solo en fácil (tres dificultades:
  vida de los enemigos x0,7, x1 y x1,2 y daño recibido x0,6, x1 y x1,3, elegidas
  en el menú); +15 % de vida por minuto desde el 3:00; jefe que invoca anillos de horda cada 15 s, con 4000 de vida; Segador
  rebajado; una ulti por personaje con R, cargada matando (180) y dibujada con
  sprites, y la del Mago apuntada con el ratón (con el mando, sola); menú de
  desarrollador (F1) en todas las versiones, con la partida fuera de récords y
  ranking, y cuyo salto de minuto da el nivel y las mejoras medidos con el
  simulador; menú de versiones con biblioteca, donde INSTALAR solo descarga y
  CAMBIAR es lo único que cambia de versión, igual en las v0.2 a v1.0
  (republicadas el 14/10).

- **Sesión 14** (decisiones de Adam, 16/10): **fase 2 y jefe final
  NÚCLEO CERO** a las 15:00 (con lo que pedía el encargo); matar al primer jefe
  no cura; el primer jefe se llama «JEFE» a secas; el ranking y los récords
  empiezan de cero (secciones nuevas `records_fase2` y `ranking_fase2` en
  `gestor_guardado.gd`: las viejas no se borran porque las versiones
  anteriores siguen escribiendo en ellas); el rootkit explosivo que invoca el
  jefe final suelta corazón y cofre, como cualquier élite; el equilibrio se
  hace al final, con el juego terminado; las versiones antiguas, en una página
  web con todas, sin seguir parcheando el menú VERSIONES. Y técnica: el reloj
  se para en las 10:00 mientras está el primer jefe y la fase 2 sigue desde
  ahí (así el tiempo siempre crece con lo que se avanza: el ranking y los
  récords lo comparan); el icono de la ventana se pone también desde
  `transicion.gd`, para que llegue con el `.pck`.

- **2D, no 3D**, para reducir el alcance (sesión 2).
- **Renderizador Compatibility** (OpenGL), no Forward+ (sesión 2).
- **Temática:** un ordenador infectado donde el jugador es un antivirus (sesión 2).
- **Idioma:** todo en castellano salvo `projecte/` y `documentacio/`, que el
  enunciado exige en catalán, y los términos técnicos sin traducción (sesión 2).
  También el informe del seguimiento y la documentación (sesión 6).
- **Horda con `MultiMeshInstance2D`, arrays de tamaño fijo y rejilla espacial.**
  Desde la sesión 12, animada con una tira de fotogramas por tipo que elige el
  shader (sigue siendo una llamada de dibujo por tipo); el troyano se voltea.
  Un enemigo de horda no es un nodo (sesión 2).
- **Las mejoras son multiplicadores y nunca modifican el `.tres`** del arma, porque
  los recursos están compartidos y en caché (sesión 2). Igual con las
  evoluciones, que se guardan en `CambioPersonaje` (sesión 6), y con las tres
  mejoras del 02/10, que actúan sobre los nodos de resistencia, cambio de
  personaje y gemas (sesión 7).
- **El `BusEventos` es la única frontera** entre sistemas (sesión 1).
- **Git:** dos ramas fijas, `main` para Adam y `feature/alan-arena-hud` para Alan,
  sin ramas por tarea; `main` siempre tiene que arrancar (sesión 3).
- **Reparto desde el 01/10:** Adam lleva todo `projecte/`, también el audio
  (sesión 6).
- **Solo dispara el arma del personaje activo**, con 10 s de espera entre cambios.
  Las armas no salen como mejoras (sesión 5).
- **Los ejecutables se publican como release de GitHub**, no dentro del
  repositorio, porque pesan más de 100 MB (sesión 5).
- **El balance se decide con el simulador de partidas**, con semillas fijas
  (sesión 4). Objetivo: **2-3 victorias de 5** desde la sesión 8 (antes 3-4),
  medido con el bot que elige mejoras como un jugador (evolución y, si no,
  ataque, recoge los premios y lanza la ulti en cuanto puede) y con 10
  partidas. Hoy da 6 de 10 (sesión 10).
- **Presión de la sesión 8** (decisiones de Adam): el doble de enemigos, +4 %
  de vida por nivel del jugador, cada nivel un 50 % más caro, experiencia que
  caduca a los 30 s. Los élites curaban el 50 % y regalaban una mejora; desde
  la sesión 9 dejan un corazón y un cofre que hay que ir a buscar.
- **Ranking local con nombre**, sin servidor (sesión 8). Adam quiere uno mundial con
  Supabase más adelante (sesión 10).
- **Un tipo de horda puede limitar cuántos hay vivos a la vez**
  (`maximo_vivos`), en lugar de repartir las apariciones con pesos: el
  ransomware, 8 (sesión 7, decisión de Adam).
- **Scripts auxiliares nuevos sin `class_name`**, cargados con `preload`, para
  que la actualización por `.pck` siga sirviendo al ejecutable v0.2 (sesión 7).
- **Mapa infinito** sin límites de arena (sesión 6).
- **Audio sintetizado por código**, sin assets de terceros (sesión 6).
- **Actualizaciones:** el juego busca solo y se actualiza al pulsar el botón;
  una release por etiqueta `vX.Y`, no por commit (sesión 6). Desde la sesión 9
  busca cada 5 minutos y avisa también en plena partida; si hace falta el
  ejecutable entero, lo instala solo. `EJECUTABLE_MINIMO` vuelve a 0.2 y solo se
  sube si el contenido no puede funcionar con un ejecutable viejo.
- **La versión web se publica con cada release** en GitHub Pages, con
  controles táctiles para el móvil, y se enlaza con un botón y un QR en el
  README y en el «About» del repositorio (sesión 9).
- **Premio de los élites** (sesión 9, decisión de Adam): corazón (cura el 50 %)
  y cofre con una ruleta de 8 sectores; cada elemento de la cola de mejoras sale
  con su panel.
- **Cada personaje tiene su vida** (sesión 9, decisión de Adam): Espadachín
  120, Segador 100, Mago 90; los que esperan se curan 1,5 por segundo; al caer
  el activo se pausa y se elige quién sigue, y se pierde al caer los tres. E
  pasa al siguiente, Q vuelve al anterior y C abre el panel del equipo.
- **Élites y jefe son nodos ocultos en la escena desde el principio**, porque
  las armas buscan sus objetivos al empezar (sesiones 5 y 6).
