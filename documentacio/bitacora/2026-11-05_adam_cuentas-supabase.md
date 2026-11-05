# 05/11/2026 — Adam — Cuentas con Supabase activadas, desplegables y v1.15

**Participantes:** Adam (con Claude Code), en el instituto, por la tarde,
después de la sesión 21 de `../bitacora.md` (es su continuación: la primera
entrada de la bitácora por sesión). **Duración y horas acumuladas:** por
apuntar (Adam iba justo de tiempo en clase; las últimas apuntadas son 48 h,
sesión 21).

## Qué se ha hecho

- **El repo para dos Claude Code** (hecho en la sesión 21): Claude explicó a
  Adam cómo trabajarán los dos y le dio el prompt para el primer día de
  Alan (crear su `CLAUDE.local.md`, rellenar `alan.md` y subirlo en un PR
  pequeño `alan/ficha`).
- **Supabase activado de verdad:**
  - Adam creó la cuenta de Supabase (con GitHub), la organización `Sector
    Cero` (plan gratis) y el proyecto `sector-cero` (región eu-west-3), y
    apagó «Confirm email». Claude no puede crear cuentas.
  - Adam conectó el **conector de Supabase** de Claude. Con él, Claude
    ejecutó el SQL de `plan_cuentas.md` (migraciones `cuentas_de_jugador` y
    `permisos_justos`), sacó la URL y la clave publicable y las puso en
    `URL` y `CLAVE` de `globales/cuenta.gd`.
  - **Permisos justos:** aunque Adam desmarcó «Automatically expose new
    tables», las tablas tenían todos los permisos para `anon` y
    `authenticated`, `TRUNCATE` incluido (que se salta el RLS). Se quitaron
    todos y se dieron solo los que usa el juego. La función `rls_auto_enable`
    (de la casilla «Enable automatic RLS») la podía llamar cualquiera: se le
    quitó `EXECUTE` (aviso de seguridad de Supabase). Avisos de seguridad y
    de rendimiento, a cero.
- **Con cuenta, la pantalla final no pide el nombre** (Adam: «se tiene que
  registrar solo»): la partida entra en el ranking con el nombre de la
  cuenta y lo dice («Guardado en el ranking como adam: puesto 3»). Al
  invitado se le sigue preguntando, porque no se sabe su nombre.
- **El simulador aparta la cuenta** (fallo visto al hacer lo anterior): con
  una sesión iniciada en el ordenador, cada partida simulada se habría
  subido a Supabase, habría entrado en el ranking y la cuenta habría bajado
  las opciones a mitad de partida (cambiando el resultado). Ahora
  `_apartar_cuenta` la desconecta y le quita el servidor, solo en memoria.
  `cuenta._arrancar` no hace nada sin servidor (sin esto salía un `ERROR`
  de URL vacía).
- **Listas desplegables en las opciones** (Adam: más intuitivo que ir
  dando clics): el límite de fps y los números de daño son un
  `OptionButton`; al pulsarlo sale la lista. Con el mando, A la abre y
  arriba y abajo se mueven por ella; izquierda y derecha siguen cambiando
  sin abrirla. La lista lleva el panel y el neón del juego (`PopupMenu` en
  `estilo_interfaz.gd`).
- **Publicada la v1.15** (novedades en `novedades/v1.15.txt`): primer PR
  del flujo nuevo (`adam/cuentas-y-equipo`), con la Action `comprobar.yml`
  estrenada.
- **Pantalla final y ranking más visuales:** empezado y dejado a medias (ver
  «Siguiente paso»).

## Decisiones y por qué

- **Probar la seguridad sin crear cuentas reales:** las 16 comprobaciones se
  hicieron con SQL, simulando dos jugadores (`set local role` y
  `request.jwt.claims`) dentro de un bloque que acaba con un error a
  propósito, así se deshace todo. Después, la base de datos estaba a 0.
- **Las cuentas reales las creó Adam desde el juego** (`adam` y `alan`): así
  se probó lo que faltaba, que Supabase acepta el email inventado
  `@sectorcero.app` y que las partidas suben.
- **La clave publicable va en el código y en GitHub:** está hecha para eso;
  lo que protege los datos son los permisos y el RLS. La secreta y la
  contraseña de la base de datos no las tiene Claude ni el repo.

## Métodos de test

- SQL contra el Supabase de verdad: el trigger crea el perfil y rechaza un
  email que no sale del nombre; nombre repetido con otras mayúsculas;
  partida ajena; cambiar y borrar partidas; partida repetida; texto enorme;
  opciones ajenas; darse una skin; estadísticas; sin cuenta (`anon`); borrar
  la cuenta borra lo suyo. 16 de 16.
- Headless: import, `--quit-after`, simulador desde el minuto 10 y el 15 con
  la sesión de Adam iniciada: los resultados de siempre (derrota con 22,
  victoria con 428), los ficheros de `user://` sin cambiar (mismo hash) y
  ninguna partida nueva en Supabase. Siguen 16 clases.
- Pantalla final (script temporal): con cuenta no hay campo de nombre y
  dice el nombre; como invitado, sí lo pide. 3 de 3.
- Con ventana: captura de la lista del límite de fps abierta debajo de su
  botón; elegir 144 lo guarda y pone `Engine.max_fps` a 144.
- Las pruebas copian antes los `.cfg` de `user://` y los dejan como estaban.

## Estado al cerrar

v1.15 publicada, con las cuentas funcionando para todos. Después, con el sí
de Adam: borrada `feature/alan-arena-hud` (sin nada fuera de `main`) y
`main` protegida en GitHub (solo con PR y la comprobación `comprobar` en
verde, también para administradores; sin aprobaciones obligatorias). Este
apunte entró ya con un PR. Pendiente de Adam: apuntar las horas.

## Siguiente paso: pantalla final y ranking más visuales (para la nube)

Adam: «cuando pierdes y salga lo de los datos, que salga más bonito; si
hace falta haz los assets oportunos para que sean más visuales las tablas
de los rankings». Visto en el instituto (capturas del estado actual):

- **Pantalla final** (`escenas/interfaz/pantalla_final.gd`): los datos son
  una rejilla de texto («Tiempo 10:52», «Nivel 14»...), «Caíste en la
  fase 2» en texto, el equipo con retratos y barras, «¡NUEVO RÉCORD!» y el
  nombre o «Guardado en el ranking».
- **Ranking** (`escenas/interfaz/panel_ranking.gd`): una tabla de texto con
  ocho columnas; solo las medallas y los mini retratos son dibujos.
- **Cuenta** (`escenas/interfaz/panel_cuenta.gd`): «tus últimas partidas»
  es una línea de texto por partida.

Propuesta de diseño (sin empezar a programar):
1. **Tarjetas de datos** en la pantalla final: tiempo, nivel, eliminados y
   dificultad, cada una con su icono de pixel art, el número grande (fuente
   pixel) y el nombre debajo; la del récord batido, con otro borde y una
   etiqueta «RÉCORD».
2. **El recorrido de la partida:** una barra con fase 1 → Kernel Panic →
   fase 2 → NÚCLEO CERO, con una marca donde acabó (sale de `donde`: «en la
   fase 1», «contra Kernel Panic», «en la fase 2», «contra NÚCLEO CERO
   (...)», «NÚCLEO CERO derrotado»; `raiz_juego.gd`, `_donde`).
3. **Ranking por filas:** cada partida una banda de 9 trozos, alterna; las
   tres primeras con el color de su medalla; la victoria o derrota como
   icono, y la dificultad como chip de su color. Resaltar las filas de la
   cuenta con la que se ha entrado.
4. **Las mismas filas en «tus últimas partidas»** de la cuenta: un script
   aparte para la fila (por ejemplo `fila_partida.gd`, con `preload` y sin
   `class_name`), que usen los dos paneles.
5. **Assets nuevos** en `medios/interfaz/`, en grises para teñirlos (como
   los del lote 9): iconos de 16 × 16 para las tarjetas (se pueden
   reutilizar el reloj y la calavera de `tecnico_iconos.png`), la tarjeta
   de 9 trozos, la banda de la fila y las marcas del recorrido. Se pueden
   generar con un script `extends SceneTree` que pinte las `Image` (como el
   generador del F3 del 05/11).
6. Scripts por debajo de ~200 líneas: `pantalla_final.gd` ya tiene unas
   230; lo nuevo, en scripts aparte.
7. Validar con capturas con ventana: la derrota y la victoria sobre la
   partida, el ranking con datos de mentira en memoria y «Texto grande».
