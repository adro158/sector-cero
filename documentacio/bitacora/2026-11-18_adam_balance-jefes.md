# 18/11/2026 — Adam — Balance de los jefes (primera parte de la issue #27)

**Participantes:** Adam (con Claude Code). **Duración:** unos 50 minutos,
sin apuntar: las horas del 18/11 van en la entrada del 19/11. **Horas
acumuladas:** 55 h, sin cambios.

## Qué se ha hecho

Adam apuntó cinco peticiones de balance en la issue #27 y pidió: «empieza
por lo más fácil de hacer. Tengo 50 minutos». Hechas tres, en la rama
`adam/balance-jefes`:

1. **El Mago contra los jefes** (`pool_proyectiles.gd`). Al rebotar, el Ping
   buscaba el objetivo más cercano sin descartar el que acababa de golpear.
   Contra un jefe, lo más cercano era el mismo jefe, así que cada proyectil
   le pegaba una vez por rebote: 5 con el Ping y 6 con el Ping de inundación.
   Ahora cada proyectil recuerda el último objetivo de un solo cuerpo que
   golpeó (jefe, élite o ancla) y no le vuelve a pegar ni a rebotar hacia él
   hasta golpear a otro. En la horda sigue igual: es un gestor con cientos.
2. **Más horda en las invocaciones**, un 50 % más:
   - Kernel Panic saca de 12 a 30 por anillo (antes, de 8 a 20).
   - Cada portal de NÚCLEO CERO saca uno cada 0,2 s (antes, 0,3): unos 13
     en vez de 8.
3. **La jaula de Kernel Panic solo encierra al jugador.** El jefe y la horda
   la cruzan. Se han quitado sus llamadas a `mantener()` (`jefe.gd` y
   `gestor_enemigos.gd`). El consejo y las reglas lo dicen.

## Decisiones técnicas y por qué

- **El rebote, no el daño**: el problema no eran los números del Mago, sino
  que el rebote volvía al mismo jefe. Arreglado eso, no hace falta bajarle
  el daño. Se recuerda solo el último golpeado (y no todos) para que un
  proyectil pueda volver al jefe después de rebotar en otro enemigo.
- **La horda de fuera también entra en la jaula**: Adam pidió que pudieran
  salir; dejarlos entrar también la hace más difícil, que es lo que busca.
- `contexto.md` dice que la jaula la respetan el jefe y la horda. Hay que
  corregirlo en el PR pequeño de `contexto.md`, junto con lo de la votación.

## Métodos de test

Simulador en media antes (copia de `main` en un worktree) y después:

| | Antes | Después |
|---|---|---|
| Desde el minuto 15 | victorias en 1055 s y 1068 s (el jefe final, en 55 y 68 s) | victorias en 1100 s y 1081 s (100 y 81 s); cae 1 personaje |
| Desde el minuto 10 | una derrota ante Kernel Panic, la otra pasa y cae en la amalgama (1142 s) | igual (1142 s); en el combate con Kernel Panic, 95 eliminados en vez de 22 |

Sin errores de script. Siguen 16 clases (no se ha añadido ninguna).

## Estado al cerrar y siguiente paso

- Hechos los puntos 1, 2 y 4 de la #27. Commit en `adam/balance-jefes`, sin
  subir.
- **Faltan:**
  - el 3, más vida en las anclas, ahora que el Ping ya no les pega varias
    veces seguidas: medir primero cuánto tardan
  - el 5, que la embestida de Kernel Panic escale con la velocidad del
    jugador
- Probarlo a mano. Probar la jaula también en red: los clientes solo
  dibujan, así que debería ir igual.
