# Planificación — Sector Cero

Reparto de las 6 fitas del enunciado entre los dos integrantes, con estimación de
horas sobre las 60 sugeridas.

- **Adam** — núcleo de jugabilidad
- **Alan** — interfaz, persistencia, audio, arena, assets y pulido visual

Las horas son una estimación inicial. Las horas reales se registran sesión a
sesión en [bitacora.md](bitacora.md).

| Fita | Total | Adam | Alan |
|---|---|---|---|
| 1 — Idea i prototip | 8 h | 5 h | 3 h |
| 2 — Core del projecte | 16 h | 12 h | 4 h |
| 3 — Experiència d'usuari | 10 h | 2 h | 8 h |
| 4 — Sistemes secundaris | 12 h | 6 h | 6 h |
| 5 — Poliment | 8 h | 4 h | 4 h |
| 6 — Entrega | 6 h | 3 h | 3 h |
| **Total** | **60 h** | **32 h** | **28 h** |

---

## Fita 1 — Idea i prototip

**Adam**

- [x] Repositorio Git con la estructura obligatoria y publicación en GitHub
- [x] Arquitectura del proyecto y contrato de integración
- [x] Proyecto de Godot configurado: autoloads, mapa de input, renderizador
- [x] Escenas base y arena de pruebas
- [x] Movimiento del jugador
- [ ] **Prototipo de la mecánica principal**: enemigos que aparecen y persiguen

**Alan**

- [ ] Instalación del entorno y clonado del repositorio
- [ ] Primeros sprites de prueba (jugador y un enemigo)
- [ ] Lectura del contrato de integración

---

## Fita 2 — Core del projecte

Es la fita más cargada y la que sostiene los 25 puntos de MVP y los 20 de calidad
de código.

**Adam**

- [ ] Sistema de enemigos con `MultiMeshInstance2D` y reciclaje desde array fijo
- [ ] Rejilla espacial para consultas de proximidad
- [ ] Fuerza de separación entre enemigos
- [ ] Colisión y daño entre enemigo y jugador
- [ ] Sistema de armas data-driven con Resources (`DatosArma`)
- [ ] Primera arma funcional y daño a enemigos
- [ ] Gemas de experiencia y recogida
- [ ] Sistema de niveles y elección de mejoras
- [ ] Director de oleadas y escalado de dificultad

**Alan**

- [ ] Escena de la arena definitiva con los grupos `aparicion_jugador` y
      `limites_arena`
- [ ] Sprites de los enemigos de horda
- [ ] Primera exportación de prueba del build

---

## Fita 3 — Experiència d'usuari

**Alan**

- [ ] Pantalla inicial
- [ ] HUD: barra de vida, barra de experiencia, temporizador, contador
- [ ] Panel de elección de mejoras al subir de nivel
- [ ] Menú de pausa
- [ ] Pantalla de resultados
- [ ] Transiciones entre escenas
- [ ] Flujo general: menú → partida → resultados → menú

**Adam**

- [ ] Emisión de todas las señales del `BusEventos` que consume la interfaz
- [ ] Números de daño flotantes

---

## Fita 4 — Sistemes secundaris

Aquí vive el elemento diferencial, que vale 15 puntos.

**Adam**

- [ ] **Elemento diferencial**: resistencia adaptativa del malware al arma más
      usada, que obliga a diversificar
- [ ] Enemigos élite con afijos procedurales (blindado, replicante, aura
      ralentizadora, explota al morir)
- [ ] Evoluciones de armas
- [ ] Jefe final

**Alan**

- [ ] Persistencia: récords, configuración y progreso
- [ ] Música y efectos de sonido
- [ ] Partículas y efectos visuales
- [ ] Shader de glitch para los enemigos de horda
- [ ] Shader de CRT a pantalla completa

---

## Fita 5 — Poliment

**Ambos**

- [ ] Corrección de errores detectados en testeo
- [ ] Ajuste de balance y sensaciones de juego
- [ ] **Validación de rendimiento en una máquina con GPU real** (no en la máquina
      virtual, donde las mediciones no son fiables)
- [ ] Testeo sistemático y registro de resultados
- [ ] Build final exportado y probado en una máquina limpia

---

## Fita 6 — Entrega

**Ambos**

- [ ] README completo: capturas, instrucciones de ejecución, controles,
      tecnologías, autores y créditos de assets
- [ ] Documentación técnica de 3-5 páginas, redactada a partir de la bitácora
- [ ] Manual de usuario (1 página)
- [ ] Fichero de créditos de assets externos con sus licencias
- [ ] Vídeo demostrativo de 2-4 minutos
- [ ] Preparación de la presentación y ensayo de la defensa

---

## Riesgos identificados

**La carga de Alan en las fitas 3 y 4 es alta.** Entre interfaz, persistencia,
audio, shaders y assets acumula la mayor parte de los 15 puntos de experiencia de
usuario. Si se retrasa, lo primero que debe recortarse son los shaders de pulido,
nunca la interfaz funcional.

**El rendimiento no se puede medir con fiabilidad en el entorno de desarrollo.**
La GPU está virtualizada. Hay que reservar tiempo en la Fita 5 para validar en
hardware real.

**El build debe probarse pronto.** El enunciado exige que el profesor pueda
ejecutar el proyecto sin abrir Godot. Descubrir problemas de exportación en la
última semana sería el peor momento posible, por lo que hay una exportación de
prueba planificada ya en la Fita 2.

**Alcance del contenido.** Cinco tipos de enemigo de horda y cinco armas es
ambicioso. Si el tiempo aprieta, se recorta contenido (tipos de enemigo, armas)
antes que sistemas, porque el enunciado valora más un proyecto pequeño y acabado
que uno grande e incompleto.
