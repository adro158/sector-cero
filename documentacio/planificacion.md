# Planificación — Sector Cero

Reparto de las 6 fitas del enunciado entre los dos integrantes, con estimación de
horas sobre las 60 sugeridas.

- **Adam** — núcleo de jugabilidad; desde el 30/09, también interfaz,
  persistencia, arena y arte; desde el 01/10, también el audio
- **Alan** — hasta el 30/09, interfaz, persistencia, arena, arte y audio; desde
  el 01/10 no tiene ficheros en `projecte/` y su parte de lo que queda está
  pendiente de acordar

Las horas son la estimación inicial, hecha con el reparto original. Las horas
reales se registran sesión a sesión en [bitacora.md](bitacora.md).

| Fita | Total | Adam | Alan |
|---|---|---|---|
| 1 — Idea i prototip | 8 h | 5 h | 3 h |
| 2 — Core del projecte | 16 h | 12 h | 4 h |
| 3 — Experiència d'usuari | 10 h | 2 h | 8 h |
| 4 — Sistemes secundaris | 12 h | 6 h | 6 h |
| 5 — Poliment | 8 h | 4 h | 4 h |
| 6 — Entrega | 6 h | 3 h | 3 h |
| **Total** | **60 h** | **32 h** | **28 h** |

Las casillas que estaban asignadas a Alan y acabó haciendo Adam llevan entre
paréntesis quién y cuándo.

---

## Fita 1 — Idea i prototip

**Adam**

- [x] Repositorio Git con la estructura obligatoria y publicación en GitHub
- [x] Arquitectura del proyecto y contrato de integración
- [x] Proyecto de Godot configurado: autoloads, mapa de input, renderizador
- [x] Escenas base y arena de pruebas
- [x] Movimiento del jugador
- [x] **Prototipo de la mecánica principal**: enemigos que aparecen y persiguen

**Alan**

- [x] Instalación del entorno y clonado del repositorio (se ve en sus commits)
- [ ] Primeros sprites de prueba (no se hicieron: los sprites salieron después de
      los scripts generadores de Adam)
- [x] Lectura del contrato de integración (su arena respetaba los grupos)

---

## Fita 2 — Core del projecte

Es la fita más cargada y la que sostiene los 25 puntos de MVP y los 20 de calidad
de código.

**Adam**

- [x] Sistema de enemigos con `MultiMeshInstance2D` y reciclaje desde array fijo
- [x] Rejilla espacial para consultas de proximidad
- [x] Fuerza de separación entre enemigos
- [x] Colisión y daño entre enemigo y jugador
- [x] Sistema de armas data-driven con Resources (`DatosArma`)
- [x] Primera arma funcional y daño a enemigos
- [x] Gemas de experiencia y recogida
- [x] Sistema de niveles y elección de mejoras
- [x] Director de oleadas y escalado de dificultad

**Alan**

- [x] Escena de la arena con el grupo `aparicion_jugador` y los límites (Alan,
      24/09; los límites se quitaron el 01/10 con el mapa infinito)
- [x] Sprites de los enemigos de horda (Adam, 30/09, generados por script)
- [x] Primera exportación de prueba del build (Adam, 29/09)

---

## Fita 3 — Experiència d'usuari

**Asignado a Alan, hecho por Adam**

- [x] Pantalla inicial con las reglas (Adam, 30/09)
- [x] HUD: barra de vida, barra de experiencia, temporizador, mejoras (Adam, 30/09)
- [x] Panel de elección de mejoras al subir de nivel (Adam, 30/09)
- [x] Menú de pausa (Adam, 30/09)
- [x] Pantalla de resultados (Adam, 30/09)
- [x] Transiciones entre escenas (Adam, 01/10)
- [x] Flujo general: menú → partida → resultados → menú (Adam, 30/09)

**Adam**

- [x] Emisión de todas las señales del `BusEventos` que consume la interfaz
- [x] Números de daño flotantes
- [x] Pausa al subir de nivel, pausa desde el bus y fin de partida con victoria
      y estadísticas
- [x] Feedback de daño al jugador (tinte y sacudida de cámara)
- [x] Personaje animado en ocho direcciones (sprite provisional)
- [x] Señales nuevas para el HUD: experiencia y tiempo
- [x] Avisos en el HUD de élites, jefe y evoluciones (01/10)

---

## Fita 4 — Sistemes secundaris

Aquí vive el elemento diferencial, que vale 15 puntos.

**Adam**

- [x] **Elemento diferencial**: resistencia adaptativa del malware al arma más
      usada, que obliga a diversificar
- [x] Cambio de personaje en plena partida, la respuesta a la resistencia (30/09)
- [x] Jefe final (30/09)
- [x] Enemigos élite con afijos procedurales: blindado, replicante, aura
      ralentizadora y explosivo (01/10)
- [x] Evoluciones de armas (01/10)
- [x] Mapa infinito (01/10)
- [x] Contenido nuevo pedido por Adam (02/10): suelo de placa base animado,
      enemigos redibujados, troyano (embiste), ransomware (tanque, 8 a la vez)
      y tres mejoras (Actualizar firmas, Cambio en caliente y Caché ampliada)
- [x] Mejoras tras las pruebas de Adam y Alan (02/10): equilibrio de
      personajes, más presión, recompensa de los élites, barras de vida,
      ficha del enemigo, experiencia que caduca y ranking

**Asignado a Alan, hecho por Adam**

- [x] Persistencia: récords y opciones (Adam, 01/10)
- [x] Música y efectos de sonido (Adam, 01/10, sintetizados por código)
- [x] Partículas y efectos visuales (Adam, 01/10)
- [x] Shader de glitch para los enemigos de horda (Adam, 01/10)
- [x] Shader de CRT a pantalla completa (Adam, 01/10)

---

## Fita 5 — Poliment

**Ambos**

- [x] Corrección de errores detectados en testeo
- [x] Ajuste de balance y sensaciones de juego con el simulador de partidas (29/09,
      01/10 y 02/10)
- [x] **Validación de rendimiento en una máquina con GPU real** (01/10, RTX 5070)
- [x] Testeo sistemático y registro de resultados (bitácora y documentación
      técnica)
- [ ] Build final exportado y probado en una máquina limpia (releases v0.2,
      01/10, y v0.3, 02/10, publicadas; falta probarlas en un ordenador sin
      Godot)

---

## Fita 6 — Entrega

**Ambos**

- [x] README completo: capturas, instrucciones de ejecución, controles,
      tecnologías, autores y créditos de assets
- [x] Documentación técnica de 3-5 páginas, redactada a partir de la bitácora
- [x] Manual de usuario (1 página)
- [x] Fichero de créditos de assets con su procedencia (`creditos.md`)
- [x] Informe del primer seguimiento
- [ ] Vídeo demostrativo de 2-4 minutos
- [x] Guion de la presentación y preguntas probables (`presentacion.md`)
- [ ] Ensayo de la defensa

---

## Riesgos identificados

**El rendimiento no se podía medir en el instituto.** La GPU de la máquina
virtual está virtualizada. Resuelto el 01/10: medido en casa con una GPU real
(ver la documentación técnica).

**El build debe probarse en una máquina limpia.** El enunciado exige que el
profesor pueda ejecutar el proyecto sin abrir Godot. El ejecutable arranca
fuera del editor, pero falta probarlo en un ordenador donde nunca se haya
instalado Godot.

**La carga de trabajo se ha concentrado en Adam.** Desde el 01/10 Alan no tiene
ficheros en el proyecto. Hay que acordar qué parte de la entrega (vídeo,
presentación, pruebas) asume, para que la defensa refleje el trabajo de los dos.

**El elemento diferencial necesitaba variedad de armas.** Resuelto: tres
personajes con una herramienta cada uno y sus tres evoluciones. Cambiar de
personaje es la decisión que da sentido a la resistencia adaptativa.
