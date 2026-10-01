# Requisitos del enunciado y estado del proyecto

Resumen en castellano de lo que pide el profesor, contrastado con lo que hay hecho.
El texto original, que es la fuente de verdad, está en `enunciat.md`; la plantilla
del primer informe, en `primer_seguiment.md`.

**Estado verificado el 01/10/2026** contra la bitácora (hasta la sesión 5, 10 h de
60) y contra el código del repositorio. Se actualiza al cerrar cada sesión, junto
con la bitácora y las casillas de `planificacion.md`.

## Qué es esto, en tres líneas

Proyecto 1 de "Demostra el teu talent": hay que crear una experiencia interactiva
en Unity o Godot que convenza a un tribunal que hace de grupo de inversores. Se
valora más un proyecto **pequeño, coherente y pulido** que uno ambicioso e
incompleto, y hay que **saber explicar y modificar cualquier línea** del código
(la IA está permitida, pero no excusa no entender lo entregado). Nuestro proyecto
es **Sector Cero**, un survivors-like 2D en Godot 4.7.2.

## Fechas

- **2 de octubre de 2026:** entrega de la propuesta (Fase 1) e informe del primer
  seguimiento (plantilla en `primer_seguiment.md`).
- Entrega final y defensa: la fecha no consta en el enunciado ni en el repositorio.
  Preguntar a Adam si hace falta.

## Requisitos mínimos (los 13 del enunciado)

| # | Requisito | Estado | Detalle |
|---|---|---|---|
| 1 | Pantalla inicial | Hecho | Menú de inicio con las reglas (`escenas/menu_principal/`) |
| 2 | Al menos dos escenas o estados | Hecho | Menú, partida, pausa y pantalla de resultados |
| 3 | Mecánica principal funcional | Hecho | Esquivar mientras las armas atacan solas; horda, jefe, experiencia y mejoras |
| 4 | Interfaz (UI/HUD) | Hecho | HUD con vida, nivel, experiencia, reloj, cuenta atrás del jefe y mejoras; panel de mejoras |
| 5 | Controles coherentes | Hecho | Teclado (WASD/flechas) y mando; pausa con Esc, P o Start; mejoras con las teclas 1, 2 y 3 |
| 6 | Pausa o menú equivalente | Hecho | Menú de pausa y pausa automática al subir de nivel |
| 7 | **Persistencia** | **Pendiente** | `globales/gestor_guardado.gd` es solo un esqueleto (`extends Node`). Previsto: récords y configuración |
| 8 | **Audio** (música o ambiente y al menos 3 efectos) | **Pendiente** | `globales/gestor_audio.gd` es un esqueleto y `medios/audio/` está vacío. Es lo único que lleva Alan |
| 9 | Animaciones o transiciones | Parcial | Hay animaciones con `Tween` en menú y pantalla final y el personaje anda en 8 direcciones. Faltan transiciones entre escenas |
| 10 | Feedback en las acciones importantes | Parcial | Visual hecho: números de daño, tinte rojo y sacudida de cámara al recibir daño. Falta el sonoro (depende del audio) y no hay partículas |
| 11 | Código estructurado | En curso | Arquitectura con bus de eventos, recursos `.tres` y escenas por responsable. Ningún script del juego pasa de 200 líneas (solo una herramienta de desarrollo, `generar_sprites.gd`, llega a 244). Revisar al final nombres y duplicados |
| 12 | Git con evolución real | En curso | Commits progresivos con convención `tipo(ámbito)` y dos ramas fijas (`main` y `feature/alan-arena-hud`) |
| 13 | Build ejecutable sin abrir el editor | Parcial | Release v0.1 en GitHub con Windows y Linux (30/09). Falta la v0.2 y probar el build final en una máquina limpia |

## Factor diferencial (al menos uno)

- **Hecho:** resistencia adaptativa del malware. Cada 20 s el malware gana un 10 %
  de resistencia (máximo 50 %) al arma que más daño le hizo y pierde un 5 % contra
  las demás. Obliga a diversificar y, desde la sesión 5, a cambiar de personaje.
- **Ampliación sin hacer:** élites con afijos procedurales
  (`enemigo_elite.gd` y `datos_afijo_elite.gd` son esqueletos).
- **Pendiente de pulido (suma en experiencia de usuario):** shader de CRT a
  pantalla completa y shader de glitch para la horda. Existen solo los shaders de
  la rejilla de la arena y del fondo provisional.

## Entregables (los 7 del enunciado)

| # | Entregable | Estado | Qué falta |
|---|---|---|---|
| 1 | Repositorio Git con historial | En curso | Seguir con commits progresivos y sincronizar al cerrar cada sesión |
| 2 | Build ejecutable | Parcial | Ver requisito 13 |
| 3 | `README.md` | Parcial | Tiene descripción, equipo, estructura, motor y flujo de Git. **Faltan** capturas de pantalla, instrucciones para ejecutarlo, controles, lista de tecnologías y créditos de assets externos |
| 4 | Documentación técnica (3-5 págs.) | Pendiente | Se redacta a partir de la bitácora. Debe cubrir arquitectura, organización del código, mecánicas, decisiones, problemas y soluciones, herramientas y assets, y **uso de la IA** |
| 5 | Manual de usuario (1 pág.) | Pendiente | Objetivo, controles e instrucciones básicas |
| 6 | Vídeo demostrativo (2-4 min) | Pendiente | |
| 7 | Presentación y defensa | Pendiente | Ver "Qué tiene que contar la presentación" |

Además, el enunciado exige **indicar la procedencia y licencia de los assets
externos**. No existe aún un fichero de créditos. Los sprites de los personajes y
del jefe se generaron con herramientas de IA de imagen y son provisionales
(bitácora, sesiones 4 y 5): tienen que quedar declarados.

## Criterios de evaluación (100 puntos)

| Apartado | Puntos | Dónde estamos |
|---|---|---|
| Funcionamiento y MVP | 25 | Jugabilidad completa. Faltan persistencia y audio del MVP |
| Programación, arquitectura y calidad del código | 20 | Buena base. Hay que poder defender cada línea |
| Experiencia de usuario, UI y pulido | 15 | Interfaz completa y sin pulir. Faltan transiciones, partículas y CRT |
| Elemento diferencial y creatividad | 15 | Resistencia adaptativa hecha |
| Robustez, testing y rendimiento | 10 | Tests en headless y simulador de partidas. **Rendimiento sin validar en GPU real** |
| Documentación y capacidad de explicar | 10 | Bitácora muy completa. Faltan README, documentación técnica y manual |
| Git, proceso y entrega | 5 | Historial progresivo. Falta la entrega final |

## Qué tiene que contar la presentación

Idea original; qué se ha construido; mecánica principal; decisiones técnicas;
**el problema técnico más difícil**; qué diferencia al proyecto; qué se mejoraría
con más tiempo; y una **demostración** en vivo. El tribunal puede preguntar por
cualquier fragmento del código.

## Lo que queda por hacer, en orden de prioridad

Primero lo que cubre los mínimos que faltan, después lo demás.

1. **Informe del primer seguimiento** (2 de octubre).
2. **Persistencia:** récords y configuración (requisito 7).
3. **Audio:** música y al menos 3 efectos (requisito 8, Alan).
4. **README completo** (capturas, ejecución, controles, tecnologías, créditos) y
   **release v0.2**.
5. **Fichero de créditos** de assets con procedencia y licencia.
6. **Pulido de feedback:** transiciones entre escenas, partículas y shader de CRT.
7. **Mapa infinito** (decidido como siguiente paso en la sesión 5).
8. **Bot del simulador** que cambie de personaje y medir el balance.
9. **Validar el rendimiento en una máquina con GPU real** (objetivo: 300+ enemigos
   a 60 FPS) y probar el build en una máquina limpia.
10. **Documentación técnica, manual de usuario, vídeo y defensa.**
11. Ampliaciones, solo si sobra tiempo: élites con afijos, evoluciones de armas.

## Decisiones vigentes (no revertir sin hablarlo con Adam)

El porqué de cada una está en `bitacora.md`, en la sesión que se indica.

- **2D, no 3D**, para reducir el alcance (sesión 2).
- **Renderizador Compatibility** (OpenGL), no Forward+ (sesión 2).
- **Temática:** un ordenador infectado donde el jugador es un antivirus (sesión 2).
- **Idioma:** todo en castellano salvo `projecte/` y `documentacio/`, que el
  enunciado exige en catalán, y los términos técnicos sin traducción (sesión 2).
- **Horda con `MultiMeshInstance2D`, arrays de tamaño fijo y rejilla espacial.**
  Un enemigo de horda no es un nodo (sesión 2).
- **Las mejoras son multiplicadores y nunca modifican el `.tres`** del arma, porque
  los recursos están compartidos y en caché (sesión 2).
- **El `BusEventos` es la única frontera** con el audio de Alan (sesión 1).
- **Prioridad a los mínimos del enunciado**; élites y evoluciones son ampliaciones
  (sesión 3).
- **Git:** dos ramas fijas, `main` para Adam y `feature/alan-arena-hud` para Alan,
  sin ramas por tarea; `main` siempre tiene que arrancar (sesión 3).
- **Reparto desde el 30/09:** Adam lleva todo menos el audio; Alan, solo el audio
  (sesión 5).
- **Solo dispara el arma del personaje activo**, con 10 s de espera entre cambios.
  Las armas ya no salen como mejoras (sesión 5).
- **Los ejecutables se publican como release de GitHub**, no dentro del
  repositorio, porque pesan 109 MB (sesión 5).
- **El balance se decide con el simulador de partidas**, con semillas fijas
  (sesión 4).
