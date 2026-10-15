# Requisitos del enunciado y estado del proyecto

Resumen en castellano de lo que pide el profesor, contrastado con lo que hay hecho.
El texto original, que es la fuente de verdad, está en `enunciat.md`; la plantilla
del primer informe, en `primer_seguiment.md`.

**Estado verificado el 15/10/2026** contra la bitácora (hasta la sesión 13) y
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
| 3 | Mecánica principal funcional | Hecho | Esquivar mientras la herramienta ataca sola; cinco tipos de horda (uno embiste), élites, jefe, experiencia, ocho mejoras y evoluciones |
| 4 | Interfaz (UI/HUD) | Hecho | HUD con vida, nivel, experiencia, reloj, cuenta atrás del jefe, mejoras, personaje activo y avisos; panel del equipo (C), ruleta del cofre y ventana para elegir quién sigue al caer un personaje |
| 5 | Controles coherentes | Hecho | Teclado, ratón en los menús y mando. Explicados en el menú, el manual y el README |
| 6 | Pausa o menú equivalente | Hecho | Menú de pausa con opciones, y pausa automática al subir de nivel |
| 7 | Persistencia | Hecho | `globales/gestor_guardado.gd`: récords (tiempo, nivel, eliminados, partidas, victorias), ranking de las 10 mejores partidas con nombre y opciones en `user://sector_cero.cfg` |
| 8 | Audio (música o ambiente y al menos 3 efectos) | Hecho | 3 músicas (menú, partida, jefe) y 17 efectos, sintetizados con `herramientas/generar_audio.gd` |
| 9 | Animaciones o transiciones | Hecho | Fundidos entre escenas, personajes en 8 direcciones (las piernas al ritmo de la velocidad), horda animada con una tira de fotogramas por tipo en el shader, glitch de la horda, destello de élites y jefe al recibir golpes, explosión del rootkit (aviso, explosión y quemadura), suelo animado (pulsos, LEDs, ventiladores), barra de experiencia que se llena y destella, tweens en menús y avisos |
| 10 | Feedback en las acciones importantes | Hecho | Números de daño, partículas, destello del enemigo golpeado, parpadeo del troyano antes de embestir, tinte y sacudida de cámara, sonidos y avisos |
| 11 | Código estructurado | Hecho | Bus de eventos, recursos `.tres`, una responsabilidad por script. El más largo del juego es `gestor_enemigos.gd` (245 líneas; la embestida va aparte, en `embestida_horda.gd`); se ha quitado el código muerto |
| 12 | Git con evolución real | Hecho | Más de 80 commits progresivos con la convención `tipo(ámbito)` |
| 13 | Build ejecutable sin abrir el editor | Casi | Releases v0.2 a v1.2 publicadas por la GitHub Action, también en la web; las anteriores se republicaron el 14 y el 15/10 con el menú VERSIONES (INSTALAR descarga sin cambiar de versión; CAMBIAR pasa a ella). Desde el juego se actualiza y se cambia a cualquier versión. Falta probarlas en un ordenador limpio |

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
| 2 | Build ejecutable | Casi | v1.2 publicada el 15/10, también en la web. Falta probarla en un ordenador limpio |
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

1. **Probarlo todo en casa** (Adam, en un chat nuevo; en el instituto no se
   puede probar jugando). Con el proyecto de `main` abierto en Godot:
   - **La explosión del rootkit** (hecha el 15/10, publicada en la v1.2): F1 →
     ÉLITE AHORA hasta que salga uno EXPLOSIVO, matarlo y mirar el aviso (se
     agrieta y tiembla, el anillo gira), la explosión y la quemadura del suelo.
   - **Lo de la v1.1** (publicada el 15/10): la horda animada y el troyano
     mirando al jugador, el destello de élites y jefe (y que el jefe no
     destelle mientras avisa en rojo), las piernas con la mejora de velocidad,
     la barra de experiencia al subir de nivel.
   - **El menú de versiones** desde la v1.1 descargada: INSTALAR una antigua
     (no cambia de versión), CAMBIAR a ella y volver.
   - **El rendimiento** con `herramientas/medir_rendimiento.gd` (con ventana),
     antes de la horda animada (etiqueta v1.0) y ahora: en el instituto da lo
     mismo dentro del ruido de la máquina virtual, que no vale para medir.
   - **La dificultad media**: decidir si se queda así o se compensa. Con la
     horda que ya no huye, el bot gana 1 de 10 (4 de 10 con la horda
     huyendo, como en la v0.9); por ejemplo, menos vida para el jefe en media.
   **La v1.2 ya está publicada** (15/10, a petición de Adam, sin probarla antes en casa): lleva la explosión del rootkit y el arreglo del F1. Si al probar sale algo, se arregla y se saca una v1.3.
2. **Arreglar el nivel del menú F1** (lo vio Adam el 15/10): al saltar a un
   minuto da un nivel muy bajo (12 en el minuto 10, y jugando Adam va por el
   14 en el 5). Falta que el bot recoja fragmentos y volver a medir las tablas
   (plan en `encargo_fase2.md`). Lo de volver al minuto 0 con las mejoras ya
   está arreglado (15/10): saltar recarga la partida; falta probarlo jugando.
3. **Fase 2 y jefe final NÚCLEO CERO en el minuto 15** (encargo de Adam del
   15/10, con dibujos suyos hechos con Claude). Encargo, plan y preguntas en
   `encargo_fase2.md`: **pendiente de que Adam diga que sí** al plan. Los
   dibujos no están en el repo: hay que descomprimir `jefe_final.zip` en la
   raíz del clon.
4. **Vídeo demostrativo** (2-4 min).
5. **Ensayar la defensa** con `presentacion.md`, que ya tiene las respuestas
   sobre el suelo, el troyano, el ransomware y Actualizar firmas.
6. **Probar en un ordenador limpio** (sin Godot) una release y su botón
   ACTUALIZAR.
7. Acordar con Alan qué parte de la entrega asume (vídeo, presentación, pruebas).
8. Más adelante: ranking mundial con Supabase (Adam crea el proyecto; Claude
   le pasa el script SQL y los pasos).
9. Opcional: sustituir los sprites de IA por pixel art propio.

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
