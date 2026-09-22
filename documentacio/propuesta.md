# Propuesta — Fase 1

**Entrega:** 2 de octubre de 2026
**Autores:** Adam y Alan

---

## Nombre provisional

**Sector Cero**

## Descripción de la idea

Un juego de acción y supervivencia en 2D con vista cenital, ambientado dentro de
un ordenador infectado.

El jugador encarna un proceso antivirus que defiende el sector de arranque del
sistema. Oleadas crecientes de malware —bits corruptos, paquetes perdidos,
gusanos, procesos colgados— convergen hacia él sin descanso. El jugador solo
controla el movimiento: las herramientas de defensa se ejecutan automáticamente,
igual que un antivirus real trabaja en segundo plano.

Al destruir malware se liberan fragmentos de datos que otorgan experiencia. Al
subir de nivel, el jugador elige entre tres mejoras, construyendo una
configuración distinta en cada partida. La partida dura entre 10 y 15 minutos y
termina con un jefe final.

Estéticamente es geométrico y de neón sobre fondo oscuro, con post-proceso de CRT
y tipografía monoespaciada: la estética de una consola de sistema.

## Tipo de proyecto

Videojuego de acción y supervivencia, del subgénero conocido como *survivors-like*
(partidas cortas, progresión dentro de la partida, combate automático y grandes
cantidades de enemigos simultáneos).

## Plataforma objetivo

PC (Windows y Linux), con entrega de un ejecutable independiente que no requiere
abrir el editor.

## Motor escogido

**Godot Engine 4.7.2**, con GDScript.

Renderizador Compatibility (OpenGL) en lugar de Forward+, decisión tomada tras
comprobar que el entorno de desarrollo no dispone de Vulkan. Tiene la ventaja
añadida de que el ejecutable final funcionará también en equipos modestos.

## Mecánica principal

Esquivar mientras el arsenal ataca solo.

El jugador nunca apunta ni dispara. Toda su capacidad de decisión está en dos
lugares: **dónde se coloca** en cada momento —para atraer enemigos, escapar de un
cerco o recoger experiencia— y **qué mejoras elige** al subir de nivel.

Esto convierte cada partida en una curva de tensión: se empieza sobrado y se
termina rodeado, y lo único que decide el resultado son las decisiones acumuladas.

## Qué queremos que sea especialmente interesante

**Un enemigo que se adapta a ti.**

En la realidad, el malware evoluciona para esquivar los antivirus que más se usan.
Lo llevamos al juego: el malware desarrolla **resistencia progresiva al arma que
más daño te está haciendo**. Cuanto más te apoyas en una herramienta, menos
efectiva se vuelve.

Esto ataca directamente el problema de diseño más típico del género —encontrar el
arma más fuerte y repetirla hasta el final— y obliga al jugador a diversificar su
configuración y a replantearse sus elecciones a mitad de partida. Es una mecánica
que nace de la ambientación en lugar de estar pegada encima.

Como segundo elemento, los enemigos élite aparecen con **afijos procedurales**
combinados al azar: blindado, replicante, aura ralentizadora, explota al morir.
Cada élite es una amenaza distinta sin necesidad de diseñarlos uno a uno.

## Tecnologías y técnicas nuevas que queremos probar

| Técnica | Por qué |
|---|---|
| Renderizado con `MultiMeshInstance2D` | Dibujar cientos de enemigos en una sola llamada de dibujado, en lugar de un nodo por enemigo |
| Rejilla espacial propia (*spatial hash*) | Resolver las consultas de proximidad sin recurrir al motor de física, que no está pensado para cientos de comprobaciones por fotograma |
| *Object pooling* | Reutilizar enemigos, proyectiles y gemas en lugar de crearlos y destruirlos constantemente |
| Diseño *data-driven* con Resources (`.tres`) | Que añadir un arma, una mejora o un tipo de enemigo sea crear un fichero de datos y no tocar código |
| Shaders | Animar la horda por shader (obligatorio al usar MultiMesh) y post-proceso de CRT |

Objetivo técnico autoimpuesto: **300 o más enemigos simultáneos a 60 FPS**.

## MVP

Lo mínimo que consideramos un proyecto entregable y acabado:

- Pantalla inicial y partida como escenas diferenciadas
- Movimiento del jugador con teclado, flechas o mando
- Tres tipos de enemigo de horda que persiguen al jugador
- Dos armas automáticas funcionales
- Experiencia, subida de nivel y elección entre tres mejoras
- Oleadas con dificultad creciente durante 10 minutos
- Un jefe final
- HUD con vida, experiencia y temporizador
- Menú de pausa y pantalla de resultados
- Persistencia de récords y configuración
- Música y al menos tres efectos de sonido
- Ejecutable exportado

Ampliaciones previstas solo si el tiempo lo permite: cinco tipos de enemigo en
lugar de tres, cinco armas en lugar de dos, evoluciones de armas, un segundo jefe
intermedio y decoración adicional del escenario.

## Reparto del trabajo

- **Adam** — núcleo de jugabilidad: movimiento, cámara, sistema de enemigos,
  colisiones, armas y daño, progresión y director de oleadas.
- **Alan** — interfaz y menús, persistencia, audio, escena de la arena, recursos
  artísticos, partículas, shaders de pulido, documentación y testeo.

Los dos sistemas se comunican a través de un bus de señales global y de recursos
de datos compartidos, de modo que ninguno depende de los ficheros del otro.

## Estado actual

A fecha de esta propuesta llevamos 4 horas de las 60 previstas. Están resueltos el
repositorio con historial progresivo, la arquitectura, la configuración del
proyecto, la escena de pruebas y el movimiento del jugador. El siguiente paso es
el prototipo del sistema de enemigos.
