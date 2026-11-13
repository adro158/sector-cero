# Reparto: quién lleva qué

Cada sistema tiene un dueño, que es quien lo cambia. Si alguien necesita un
cambio en un sistema que no es suyo, abre una issue o comenta en el PR del
dueño. Se actualiza cada vez que se reparte algo nuevo (en un PR, como todo).

| Sistema | Ficheros | Dueño |
|---|---|---|
| Jugabilidad: jugador, personajes, armas, ultis | `escenas/jugabilidad/jugador/`, `escenas/jugabilidad/armas/` | Adam |
| Enemigos, élites, jefes | `escenas/jugabilidad/enemigos/` | Adam |
| Oleadas, progresión, efectos, depuración (F1, F3) | `escenas/jugabilidad/oleadas/`, `progresion/`, `efectos/`, `depuracion/` | Adam |
| Interfaz y menús | `escenas/interfaz/`, `escenas/menu_principal/` | Adam |
| Arena y shaders | `escenas/arena/`, `medios/shaders/` | Adam |
| Audio | `globales/gestor_audio.gd`, `medios/audio/` | Adam |
| Persistencia, opciones, entrada (mando, F11) | `globales/gestor_guardado.gd`, `globales/entrada.gd` | Adam |
| Cuentas (Supabase) | `globales/cuenta*.gd`, `escenas/interfaz/panel_cuenta.gd`, `documentacio/plan_cuentas.md` | Adam |
| Actualizador, versiones, lanzador, Actions | `globales/actualizador.gd`, `globales/version.gd`, `lanzador/`, `.github/` | Adam |
| Recursos de datos (`.tres`) y arte | `recursos/`, `medios/` (menos audio y shaders) | Adam |
| Multijugador: la red y la sala (06/11, `plan_multijugador.md`) | `globales/red.gd`, `escenas/red/` | Adam (desde el 13/11; antes Alan, que hizo la prueba de conexión) |
| Multijugador: el juego con varios jugadores | lo de Adam de arriba (jugador, enemigos, interfaz...) | Adam |
| Documentos de Alan | `documentacio/assets.md`, `documentacio/propuesta.md` | Alan |
| Entregables y seguimiento | `documentacio/` (el resto) | Adam |

**Ficheros de paso** (los toca todo el mundo): `projecte/project.godot`,
`escenas/juego.tscn`, `escenas/jugabilidad/raiz_juego.tscn`,
`globales/bus_eventos.gd`, `CLAUDE.md` y `documentacio/equipo/`. Los cambios
en ellos van en un PR pequeño y aparte, que se fusiona antes que el resto.

## El multijugador (planeado el 06/11)

Así se hace, con el detalle y las decisiones en `documentacio/plan_multijugador.md`:

1. **Un PR pequeño de contrato**: `documentacio/plan_multijugador.md` con las
   decisiones, las señales nuevas del bus y el reparto. Lo revisan los dos y
   se fusiona.
2. **Dos ramas en paralelo**, cada una con su PR:
   - `alan/red`: la conexión (`ENetMultiplayerPeer`), el anfitrión, buscar
     partida en la red local y mandar el movimiento de cada jugador.
   - `adam/varios-jugadores`: el juego con varios jugadores (la horda, los
     jefes, la cámara y el grupo `jugador` con más de uno).
3. **Un PR de integración** que lo junta, probado por la Action y jugando.

**Cambio del 13/11 (decisión de Adam):** la red y la sala pasan a Adam, que
las hace con su Claude para acabar el online (Adam avisa a Alan). Se parte
de la prueba de conexión de Alan (`alan/red`, 09/11). De Alan sigue haciendo
falta probar con dos ordenadores de verdad que la red del instituto deja
conectar: Claude solo puede probar dos copias del juego en el mismo
ordenador.
