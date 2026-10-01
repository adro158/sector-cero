# Informe del primer seguimiento — Sector Cero

**Autores:** Adam y Alan · **Fecha:** 2 de octubre de 2026 · **Motor:** Godot
4.7.2 (GDScript)

Sigue la estructura de la plantilla del profesor (`primer_seguiment.md`).

## 1. Resumen del estado y avance

### Porcentaje de avance

Llevamos **12 h de las 60 sugeridas (20 %)**. En
funcionalidades vamos bastante por delante de las horas: están cubiertos los
13 requisitos mínimos del enunciado y todo el MVP de la propuesta, y también las
ampliaciones que habíamos dejado para el final (élites con afijos y evoluciones
de armas). Lo que queda es sobre todo de la Fita 6: vídeo, presentación y
ensayo de la defensa, y probar el ejecutable en un ordenador limpio.

| Fita | Estado |
|---|---|
| 1 — Idea y prototipo | Hecha |
| 2 — Core del proyecto | Hecha |
| 3 — Experiencia de usuario | Hecha |
| 4 — Sistemas secundarios | Hecha, con las ampliaciones |
| 5 — Pulido | Casi hecha: balance medido, rendimiento validado en GPU real, build v0.2. Falta probar el build en un ordenador limpio |
| 6 — Entrega | En curso: README, documentación técnica, manual y créditos hechos. Faltan el vídeo y la presentación |

### Fitas cubiertas

- **Fita 1 (planificación y montaje):** repositorio con la estructura del
  enunciado, arquitectura, proyecto de Godot configurado, escenas base y
  prototipo de la mecánica.
- **Fita 2 (mecánica principal):** horda con `MultiMeshInstance2D`, rejilla
  espacial, armas definidas con datos, experiencia, niveles y mejoras, director
  de oleadas con dificultad creciente.

### Qué es jugable

Una partida completa de principio a fin: menú inicial con las reglas, partida de
10 minutos con horda creciente, tres personajes intercambiables, mejoras y
evoluciones, élites cada minuto, jefe final, pausa, pantalla de resultados con
récords, y vuelta al menú. Se puede jugar con el ejecutable de Windows o Linux
sin abrir Godot.

**Demostración:** se arranca el ejecutable, se juega un par de minutos para
enseñar la resistencia adaptativa (los números se vuelven rojos y se cambia de
personaje con Q), una subida de nivel y la llegada de un élite, y con F3 se
abre el panel técnico que enseña la resistencia en directo.

## 2. Implementación del MVP y funcionalidad central

### Mecánica principal

**Funcional.** El jugador se mueve y su herramienta ataca sola; la horda le
persigue y le hace daño por contacto; el malware muere, suelta experiencia y el
jugador sube de nivel y elige mejoras. El elemento diferencial (la resistencia
adaptativa del malware a la herramienta que más daño le hace) funciona y obliga
a cambiar de personaje.

### Estructura de escenas

Las escenas previstas están creadas y conectadas:

- **Menú principal** (`menu_principal.tscn`): reglas, controles, récord y
  opciones.
- **Partida** (`juego.tscn`): arena, jugabilidad e interfaz.
- Además, estados dentro de la partida: pausa, subida de nivel y pantalla de
  resultados.

### Controles

Operativos con **teclado** (WASD o flechas para moverse, Q o Tab para cambiar
de personaje, Esc o P para pausar, 1-2-3 para elegir mejora), **ratón** en
todos los menús y **mando** (stick, Y, Start y A).

## 3. Calidad técnica y estructuras básicas

### Calidad del código

La plantilla habla de C#; nosotros usamos **GDScript**, el lenguaje de Godot.
Criterios que seguimos:

- **Modular:** cada sistema es un nodo con su script (jugador, gestores de
  enemigos, armas, niveles, director de oleadas...) y se comunican por un bus de
  señales, sin referencias directas entre sistemas.
- **Basado en datos:** armas, mejoras, enemigos, afijos, personajes y oleadas
  son recursos `.tres`; añadir uno es crear un fichero.
- **Limpio:** nombres descriptivos en castellano, scripts de alrededor de 200
  líneas o menos, comentarios que explican el porqué y sin código muerto (se
  ha ido quitando lo que dejaba de usarse).

### Control de versiones

Repositorio en GitHub con **más de 70 commits** progresivos desde el 18 de
septiembre, con la convención `tipo(ámbito): descripción`. Dos ramas fijas
(`main` y la de Alan) que se fusionan al empezar cada clase. Los ejecutables se
publican como *releases* (v0.1 el 30/09 y v0.2), no dentro del repositorio,
porque pesan más de 100 MB.

### Árbol de assets

```
projecte/
├── escenas/     escenas con sus scripts y sprites propios de cada una
├── recursos/    datos (.tres), sprites de enemigos e iconos de mejoras
├── medios/      audio y shaders
└── herramientas/ scripts que generan los sprites y el audio
```

**Todos los assets son propios o generados**, salvo los sprites de los
personajes y del jefe, hechos con IA (idea con Gemini y hojas de sprites con
Claude) a partir de un ejemplo que compartió el profesor. No hay assets
descargados de terceros. La procedencia de cada uno está en `creditos.md` y en
el README.

## 4. Próximos pasos y gestión de riesgos

### Foco inmediato

Las Fitas 3 (UI y UX) y 4 (persistencia, audio y animaciones) están hechas:

- **UI y UX:** menú con reglas, HUD (nivel, experiencia, reloj, cuenta atrás
  del jefe, mejoras, personaje activo), panel de mejoras, pausa, opciones y
  resultados, con fundidos entre pantallas y avisos de élites y jefe.
- **Persistencia:** récords y opciones guardados en disco.
- **Audio:** música de menú, partida y jefe, y 17 efectos.
- **Animaciones y efectos:** personajes en 8 direcciones, partículas, destellos,
  glitch de la horda, sacudida de cámara y filtro CRT.

Lo siguiente es la Fita 6: grabar el vídeo, preparar la presentación y ensayar
la defensa, además de probar el ejecutable en un ordenador limpio.

**Revisión del alcance:** el MVP está cubierto con margen antes de las 60 horas.
No vamos a añadir más contenido; las horas que quedan son para pulir, probar y
preparar la defensa.

### Incidencias y desviaciones

- **Reparto del trabajo.** El 30/09, la interfaz, la persistencia, la arena y el
  arte pasaron de Alan a Adam, porque la interfaz dependía mucho de la
  jugabilidad. El 01/10 también el audio, que estaba sin empezar y es un
  requisito mínimo. *Mitigación:* el audio se genera por código, así que no
  depende de buscar ni licenciar sonidos.
- **Alcance.** Vamos por delante en funcionalidades: hemos hecho las
  ampliaciones de la propuesta (élites y evoluciones) y un mapa infinito.
- **Entorno.** La máquina virtual del instituto no tiene GPU real. *Mitigación:*
  el rendimiento se ha medido en un PC con GPU real.

### Testing

- **Ejecución sin ventana** de cada cambio para detectar errores.
- **Pruebas dirigidas** con scripts temporales: récords guardados en disco, cola
  de niveles, los cuatro afijos de los élites, las evoluciones, la pausa.
- **Simulador de partidas** con un bot y semillas fijas para el balance: tras
  el mapa infinito el juego era demasiado fácil y el jefe demasiado duro; tras
  los ajustes, el bot gana 4 de 5 partidas.
- **Rendimiento** medido en una GPU real (RTX 5070): 300 enemigos a unos
  1500 FPS y 1200 enemigos a más de 700 FPS, con la física en 9 ms de los
  16,7 ms que hay por fotograma a 60 FPS. El objetivo de la propuesta era 300
  enemigos a 60 FPS.
- **Capturas con ventana** de todas las pantallas.
