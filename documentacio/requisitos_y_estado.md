# Requisitos del enunciado y estado del proyecto

Resumen en castellano de lo que pide el profesor, contrastado con lo que hay hecho.
El texto original, que es la fuente de verdad, está en `enunciat.md`; la plantilla
del primer informe, en `primer_seguiment.md`.

**Estado verificado el 02/10/2026** contra la bitácora (hasta la sesión 7,
14 h de 60) y contra el código del repositorio. Se actualiza al
cerrar cada sesión, junto con la bitácora y las casillas de `planificacion.md`.

## Qué es esto, en tres líneas

Proyecto 1 de "Demostra el teu talent": hay que crear una experiencia interactiva
en Unity o Godot que convenza a un tribunal que hace de grupo de inversores. Se
valora más un proyecto **pequeño, coherente y pulido** que uno ambicioso e
incompleto, y hay que **saber explicar y modificar cualquier línea** del código
(la IA está permitida, pero no excusa no entender lo entregado). Nuestro proyecto
es **Sector Cero**, un survivors-like 2D en Godot 4.7.2.

## Fechas

- **2 de octubre de 2026:** entrega de la propuesta (Fase 1) e informe del primer
  seguimiento (redactado en `informe_primer_seguimiento.md`).
- Entrega final y defensa: la fecha no consta en el enunciado ni en el repositorio.
  Preguntar a Adam si hace falta.

## Requisitos mínimos (los 13 del enunciado)

| # | Requisito | Estado | Detalle |
|---|---|---|---|
| 1 | Pantalla inicial | Hecho | Menú con reglas, controles, récord y opciones (`escenas/menu_principal/`) |
| 2 | Al menos dos escenas o estados | Hecho | Menú, partida, pausa, opciones, subida de nivel y resultados |
| 3 | Mecánica principal funcional | Hecho | Esquivar mientras la herramienta ataca sola; cinco tipos de horda (uno embiste), élites, jefe, experiencia, ocho mejoras y evoluciones |
| 4 | Interfaz (UI/HUD) | Hecho | HUD con vida, nivel, experiencia, reloj, cuenta atrás del jefe, mejoras, personaje activo y avisos |
| 5 | Controles coherentes | Hecho | Teclado, ratón en los menús y mando. Explicados en el menú, el manual y el README |
| 6 | Pausa o menú equivalente | Hecho | Menú de pausa con opciones, y pausa automática al subir de nivel |
| 7 | Persistencia | Hecho | `globales/gestor_guardado.gd`: récords (tiempo, nivel, eliminados, partidas, victorias) y opciones en `user://sector_cero.cfg` |
| 8 | Audio (música o ambiente y al menos 3 efectos) | Hecho | 3 músicas (menú, partida, jefe) y 17 efectos, sintetizados con `herramientas/generar_audio.gd` |
| 9 | Animaciones o transiciones | Hecho | Fundidos entre escenas, personajes en 8 direcciones, glitch de la horda, suelo animado (pulsos, LEDs, ventiladores), tweens en menús y avisos |
| 10 | Feedback en las acciones importantes | Hecho | Números de daño, partículas, destello del enemigo golpeado, parpadeo del troyano antes de embestir, tinte y sacudida de cámara, sonidos y avisos |
| 11 | Código estructurado | Hecho | Bus de eventos, recursos `.tres`, una responsabilidad por script. El más largo del juego es `gestor_enemigos.gd` (245 líneas; la embestida va aparte, en `embestida_horda.gd`); se ha quitado el código muerto |
| 12 | Git con evolución real | Hecho | Más de 80 commits progresivos con la convención `tipo(ámbito)` |
| 13 | Build ejecutable sin abrir el editor | Casi | Releases v0.2 (01/10), v0.3 y v0.4 (02/10, con el contenido nuevo) publicadas por la GitHub Action. Falta probarlas en un ordenador limpio |

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
| 2 | Build ejecutable | Casi | v0.4 publicada el 02/10. Falta probarla en un ordenador limpio |
| 3 | `README.md` | Hecho | Capturas, ejecución, controles, tecnologías, autores y créditos |
| 4 | Documentación técnica (3-5 págs.) | Hecho | `documentacion_tecnica.md` |
| 5 | Manual de usuario (1 pág.) | Hecho | `manual_usuario.md` |
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

1. **Entregar el informe del primer seguimiento** (hoy, 2 de octubre):
   `informe_primer_seguimiento.md`. Está redactado con el estado del 01/10: no
   menciona el contenido del 02/10.
2. **Probar en un ordenador limpio** (sin Godot) la v0.2 y el botón
   ACTUALIZAR hacia la v0.4, publicada el 02/10 con ejecutable mínimo 0.2.
3. **Vídeo demostrativo** (2-4 min).
4. **Ensayar la defensa** con `presentacion.md`, que ya tiene las respuestas
   sobre el suelo, el troyano, el ransomware y Actualizar firmas.
5. Acordar con Alan qué parte de la entrega asume (vídeo, presentación, pruebas).
6. Opcional: sustituir los sprites de IA por pixel art propio.

## Decisiones vigentes (no revertir sin hablarlo con Adam)

El porqué de cada una está en `bitacora.md`, en la sesión que se indica.

- **2D, no 3D**, para reducir el alcance (sesión 2).
- **Renderizador Compatibility** (OpenGL), no Forward+ (sesión 2).
- **Temática:** un ordenador infectado donde el jugador es un antivirus (sesión 2).
- **Idioma:** todo en castellano salvo `projecte/` y `documentacio/`, que el
  enunciado exige en catalán, y los términos técnicos sin traducción (sesión 2).
  También el informe del seguimiento y la documentación (sesión 6).
- **Horda con `MultiMeshInstance2D`, arrays de tamaño fijo y rejilla espacial.**
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
  (sesión 4). Objetivo: 3-4 victorias de 5 (sesión 6), medido desde la sesión 7
  con el bot que elige mejoras como un jugador (evolución y, si no, ataque) y
  con 10 partidas. Hoy da 8 de 10.
- **Un tipo de horda puede limitar cuántos hay vivos a la vez**
  (`maximo_vivos`), en lugar de repartir las apariciones con pesos: el
  ransomware, 8 (sesión 7, decisión de Adam).
- **Scripts auxiliares nuevos sin `class_name`**, cargados con `preload`, para
  que la actualización por `.pck` siga sirviendo al ejecutable v0.2 (sesión 7).
- **Mapa infinito** sin límites de arena (sesión 6).
- **Audio sintetizado por código**, sin assets de terceros (sesión 6).
- **Actualizaciones:** el juego busca solo y se actualiza al pulsar el botón;
  una release por etiqueta `vX.Y`, no por commit (sesión 6).
- **Élites y jefe son nodos ocultos en la escena desde el principio**, porque
  las armas buscan sus objetivos al empezar (sesiones 5 y 6).
