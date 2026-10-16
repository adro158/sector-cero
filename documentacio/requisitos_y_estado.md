# Requisitos del enunciado y estado del proyecto

Resumen en castellano de lo que pide el profesor, contrastado con lo que hay hecho.
El texto original, que es la fuente de verdad, está en `enunciat.md`; la plantilla
del primer informe, en `primer_seguiment.md`.

**Estado verificado el 16/10/2026** contra la bitácora (hasta la sesión 14) y
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
| 9 | Animaciones o transiciones | Hecho | Fundidos entre escenas, personajes en 8 direcciones (las piernas al ritmo de la velocidad), horda animada con una tira de fotogramas por tipo en el shader, glitch de la horda, destello de élites y jefe al recibir golpes, explosión del rootkit (aviso, explosión y quemadura), transición a negro de la fase 2, jefe final (tres formas, transformación, muerte, ataques, escudo y hielo), suelo animado (pulsos, LEDs, ventiladores; en la fase 2, chispazos y humo), barra de experiencia que se llena y destella, tweens en menús y avisos |
| 10 | Feedback en las acciones importantes | Hecho | Números de daño, partículas, destello del enemigo golpeado, parpadeo del troyano antes de embestir, tinte y sacudida de cámara, sonidos y avisos |
| 11 | Código estructurado | Hecho | Bus de eventos, recursos `.tres`, una responsabilidad por script. Los más largos pasan de las ~200 líneas orientativas, contando comentarios: `gestor_enemigos.gd` (388; la embestida y el volteo van aparte), `jefe_final.gd` (302; los ataques, el escudo, las anclas, el hielo y el dibujo van en sus scripts) y `ataques_jefe_final.gd` (257); se ha quitado el código muerto |
| 12 | Git con evolución real | Hecho | Más de 80 commits progresivos con la convención `tipo(ámbito)` |
| 13 | Build ejecutable sin abrir el editor | Casi | Releases v0.2 a v1.3 publicadas por la GitHub Action, también en la web; las anteriores se republicaron el 14 y el 15/10 con el menú VERSIONES (INSTALAR descarga sin cambiar de versión; CAMBIAR pasa a ella). Desde el juego se actualiza y se cambia a cualquier versión. Falta probarlas en un ordenador limpio |

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
| 2 | Build ejecutable | Casi | v1.3 publicada el 16/10, también en la web, ya con su icono. Falta probarla en un ordenador limpio |
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

1. **Probar jugando la fase 2 y el jefe final** (hechos el 16/10, sin
   publicar; la lista paso a paso está en la bitácora, sesión 14). Con el
   proyecto de `main` abierto en Godot o con la build:
   - F1 → JEFE YA: matarlo y mirar el negro de la transición, el suelo
     dañado, la música más grave y que el reloj se queda en 10:00 mientras
     está el jefe.
   - F1 → JEFE FINAL YA (15:00) y SIGUIENTE FORMA: las tres formas, cada
     ataque (que el aviso se entienda y se pueda esquivar), el escudo con sus
     anclas, el hielo, la barra de vida, la muerte y la victoria.
   - Una partida normal mirando el nivel con F3 en los minutos 5, 10 y 15:
     las tablas del F1 (medidas otra vez el 16/10 con el bot que recoge
     fragmentos: nivel 13 en el minuto 10) siguen por debajo de lo que vio
     Adam (nivel 14 en el minuto 5).
   - Al abrir la versión nueva, el ranking y los récords salen vacíos (y la
     v1.2, si se vuelve a ella, sigue teniendo los suyos).
   - Lo de antes que aún no se ha probado jugando: la explosión del rootkit
     (v1.2) y lo de la v1.1 (horda animada, destellos, piernas, barra de
     experiencia).
2. **Equilibrar la fase 2 y el jefe final, al final** (decisión de Adam del
   16/10). Con el simulador, 10 partidas: fácil, 5 victorias (las otras 5
   mueren en la fase 2); media, ninguna (5 contra el jefe, 4 al poco de
   empezar la fase 2); difícil, ninguna. Ideas para entonces: unos segundos
   sin horda al volver la imagen, que la vida por minuto deje de subir a las
   10:00 o que la horda de la fase 2 empiece más suave y vuelva a apretar; y
   decidir cuántas victorias se quieren en cada dificultad.
3. **La v1.3, publicada el 16/10** a petición de Adam, sin que la haya
   probado él jugando: fase 2, jefe final e icono. No hay `class_name` nuevos
   y `project.godot` solo cambia el icono: `EJECUTABLE_MINIMO` sigue en 0.2. El
   icono de la ventana llega con el `.pck` (lo pone `transicion.gd`) y el del
   `.exe`, con el ejecutable nuevo. Si al probar sale algo, se arregla y se
   saca una v1.4.
4. **Versiones: una página web con todas** (decidido el 16/10, bitácora,
   sesión 14: no se sigue parcheando el menú VERSIONES, que con la v1.1
   instalada y la v1.0 en uso ofrecía INSTALAR la v1.0). Cada versión se
   publicará en GitHub Pages en su carpeta (`/v0.3/`, `/v1.2/`...) con una
   portada que las liste; el juego de escritorio se queda con ACTUALIZAR y el
   botón VERSIONES abrirá esa página. Las anteriores a la v0.9 no tenían
   exportación web: hay que añadírsela al compilarlas y probarlas una a una.

   **Sin decidir del todo (16/10, en clase):** Adam propuso un lanzador
   aparte, como el de Minecraft. Primero una pantalla con la información del
   juego y la lista de versiones, y al pulsar JUGAR se abre esa versión, sin
   cerrar y reiniciar el juego. Lo que propuso Claude:
   - un ejecutable aparte (`SectorCero_Lanzador`) del mismo proyecto: su
     preset de exportación lleva una marca y arranca en la pantalla del
     lanzador en vez de en el juego
   - la lista de versiones sale de la API de releases de GitHub, así que las
     nuevas aparecen sin actualizar el lanzador
   - INSTALAR o JUGAR por versión: baja el zip a la biblioteca reutilizando
     `instalador_juego.gd` y la abre con `OS.create_process`
   - el juego se queda solo con ACTUALIZAR, o sin nada, porque las versiones
     nuevas las trae el lanzador

   Unas 2 sesiones más las pruebas. Cada versión pesa unos 40 MB de descarga
   y unos 110 MB instalada: se baja solo la que se elige. Las versiones
   antiguas seguirán teniendo su menú VERSIONES. En la web no puede haber
   lanzador, así que la página con todas sigue haciendo falta allí.
   Recomendación de Claude: las dos cosas, pero detrás del vídeo y del ensayo
   de la defensa. **Falta que Adam decida.**
5. **Icono del juego: publicado en la v1.3** (bitácora, sesión 14). Lo dibujó
   Claude a partir de la idea de Adam (`medios/icono/`). El 16/10 Adam vio
   que en Linux no salía. Un ejecutable de Linux no lleva icono, y GNOME en
   Wayland no usa el de la ventana: lo saca de un `.desktop` instalado. Desde
   entonces, el juego exportado escribe al arrancar en Linux
   `~/.local/share/applications/sector-cero.desktop` y su icono
   (`globales/icono_linux.gd`, lo llama `transicion.gd`). Probado en headless
   en Windows; **falta probarlo en un Linux de verdad** y publicarlo. Si la
   ventana sigue sin icono en el dock, mirar que `StartupWMClass` ("Sector
   Cero") coincida con la clase de la ventana (`xprop WM_CLASS` en X11).
   En Windows, quien actualizó solo con el `.pck` tiene el `.exe` con el icono
   viejo: llega bajando el zip, o subiendo `EJECUTABLE_MINIMO` en la v1.4 (por
   decidir con Adam).
   - el `.exe`: preset de Windows (`application/icon`, el `.ico`); probado
     exportando en casa
   - la ventana: `config/icon` y `config/windows_native_icon` de
     `project.godot`, y además `transicion.gd` lo pone al arrancar, para que
     llegue también con el `.pck` a los ejecutables viejos; probado con
     ventana
   - la web: el favicon sale de `config/icon` (`html/export_icon=true`).
     Falta mirarlo en la web publicada: en casa no están las plantillas web
   - para que llegue a los jugadores basta una release normal: el `.pck`
     trae el icono de la ventana y el ejecutable nuevo, el del `.exe`. No hace
     falta subir `EJECUTABLE_MINIMO`
6. **Vídeo demostrativo** (2-4 min).
7. **Ensayar la defensa** con `presentacion.md`, que ya tiene las respuestas
   sobre el suelo, el troyano, el ransomware y Actualizar firmas.
8. **Probar en un ordenador limpio** (sin Godot) una release y su botón
   ACTUALIZAR.
9. Acordar con Alan qué parte de la entrega asume (vídeo, presentación, pruebas).
10. Más adelante: ranking mundial con Supabase (Adam crea el proyecto; Claude
   le pasa el script SQL y los pasos).
11. Opcional: sustituir los sprites de IA por pixel art propio.

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
