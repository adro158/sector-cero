# Plan: cuentas de jugador con Supabase

Propuesta del 05/11/2026 (sesión 21).

**Estado (05/11, por la noche): activado.** Adam creó el proyecto
`sector-cero` (organización `Sector Cero`, plan gratis, región eu-west-3) y
apagó «Confirm email». Claude, con el conector de Supabase, ejecutó el SQL de
abajo, dejó los permisos justos y puso la URL y la clave publicable en `URL` y
`CLAVE` de `projecte/globales/cuenta.gd`. Los avisos de seguridad y
rendimiento de Supabase, a cero.

Probado contra el Supabase de verdad con SQL, simulando dos jugadores dentro
de una transacción que se deshace (no se crea ninguna cuenta), con 16
comprobaciones en verde:
- el trigger crea el perfil y rechaza un email que no sale del nombre
- nombre repetido con otras mayúsculas, rechazado
- cada uno sube sus partidas pero no las de otro, y no las puede cambiar ni
  borrar
- la partida repetida y los textos enormes, rechazados
- las opciones: cada uno ve y cambia solo las suyas
- nadie se puede dar una skin
- las estadísticas salen bien
- sin cuenta se leen las partidas, pero no se sube nada ni se ven opciones
- borrar una cuenta borra todo lo suyo

Desde el juego, probado por Adam creando las cuentas `adam` y `alan`
(abajo).

**Decisiones de Adam (05/11):**
- **Al abrir el juego sale la bienvenida** (entrar o crear cuenta), con
  **JUGAR SIN CUENTA** para quien no quiera o no tenga conexión.
- **Quien entra una vez, entra solo después:** la sesión se recuerda (nunca
  la contraseña) hasta SALIR DE LA CUENTA.
- **En la cuenta se guarda:**
  - cada partida
  - los récords y las estadísticas, calculados en el servidor
  - las opciones: menos pantalla completa, límite de fps y aviso de
    versiones, que son de cada ordenador
  - un inventario vacío, preparado para las skins
- Sin ranking mundial todavía.
- **Con cuenta, el ranking no pide el nombre** (05/11, tras probarlo): la
  partida se guarda sola con el de la cuenta. Al invitado se le sigue
  preguntando.
- El simulador aparta la cuenta (solo en memoria): con una sesión iniciada en
  el ordenador, las partidas simuladas no se suben ni entran en el ranking.

**Primeras cuentas (05/11):** `adam` y `alan`, creadas por Adam desde el
juego: Supabase acepta el email `@sectorcero.app` y las partidas suben.

## Qué queremos

**Ahora:** cada jugador tiene una cuenta con **usuario y contraseña**, y en
ella se guardan **todas sus partidas**.

**Más adelante** (sin concretar): logros y un pase de batalla con skins. Las
tablas de ahora se diseñan para que eso se añada sin tocarlas.

## Cómo funciona, en una imagen

```
  JUEGO (Godot)                         SUPABASE (servidor, gratis)
  ─────────────                         ──────────────────────────
  Panel CUENTA ── usuario+contraseña ─▶ Auth: guarda la contraseña
                ◀── token de sesión ──     cifrada y da un token
  Fin de partida ── la partida + token ▶ Tabla «partidas»: solo
                                           deja añadir las tuyas (RLS)
  Menú ─────────── pide el ranking ─────▶ Tabla «partidas»: se puede leer
```

El juego habla con Supabase con peticiones HTTP normales (`HTTPRequest` de
Godot): no hace falta ninguna librería ni plugin.

## Decisiones propuestas (a confirmar)

| Pregunta | Propuesta | Por qué |
|---|---|---|
| ¿Es obligatorio entrar? | **No: se puede jugar como invitado**, como ahora | El tribunal y el profesor tienen que poder jugar sin crearse una cuenta, y el juego tiene que ir sin internet |
| ¿Email? | **No: solo usuario y contraseña** | Menos datos personales. Supabase pide un email; el juego le manda uno inventado a partir del usuario |
| Nombre de usuario | 3 a 14 letras, números o `_`, único sin mirar mayúsculas | El mismo límite que el nombre del ranking de ahora |
| Contraseña | Mínimo 6 caracteres (el de Supabase) | Nunca se guarda en el ordenador: solo el token de sesión |
| ¿Las partidas con trucos (F1)? | **No se suben** | Ya no cuentan para los récords locales |
| ¿Quién ve las partidas? | **Todo el mundo puede leerlas; cada uno solo añade las suyas** | Hace falta para el ranking mundial y no hay nada privado en una partida |
| ¿Récords y ranking locales? | **Se quedan** como están | El invitado los sigue teniendo |

## Paso 1: crear el proyecto de Supabase (hecho el 05/11)

Claude no puede crear cuentas: la cuenta, la organización y el proyecto los
crea Adam. Con el conector de Supabase de Claude conectado, los pasos 4 y 5
los puede hacer Claude (así se hizo el 05/11).

1. Entrar en [supabase.com](https://supabase.com) y crear una cuenta (se
   puede con la de GitHub).
2. **New project**: nombre `sector-cero`, región de Europa. Apuntar la
   contraseña de la base de datos en un sitio seguro (**no** en el repo).
3. **Authentication → Sign In / Providers → Email**: dejarlo activado y
   **desactivar «Confirm email»**. Así no se envía ningún correo y se entra
   nada más crear la cuenta.
4. **SQL Editor → New query**: pegar el SQL de abajo y darle a **Run**.
5. **Project Settings → API Keys**: copiar la **URL del proyecto** y la
   **clave publicable** (`sb_publishable_…`) y pasárselas a Claude. Esas dos
   sí pueden ir en el código: están hechas para eso, y lo que protege los
   datos son las reglas (RLS) del SQL.

**Nunca** pasar a nadie ni poner en el juego la **clave secreta**
(`sb_secret_…`, la antigua `service_role`) ni la contraseña de la base de
datos.

## Paso 2: el SQL (copiar y pegar en el SQL Editor)

```sql
-- Un perfil por cuenta: el nombre que se ve en el juego.
create table public.perfiles (
  id uuid primary key references auth.users (id) on delete cascade,
  nombre text not null check (nombre ~ '^[A-Za-z0-9_]{3,14}$'),
  creado timestamptz not null default now()
);
-- Único sin mirar mayúsculas: «Adam» y «adam» son el mismo.
create unique index perfiles_nombre_unico on public.perfiles (lower(nombre));

-- Cada partida terminada de un jugador con cuenta. Las mismas claves que
-- trae partida_terminada en el juego.
create table public.partidas (
  id bigint generated always as identity primary key,
  usuario uuid not null default auth.uid() references public.perfiles (id) on delete cascade,
  jugada timestamptz not null default now(),
  victoria boolean not null,
  tiempo real not null check (tiempo >= 0),
  nivel int not null check (nivel >= 1),
  eliminados int not null check (eliminados >= 0),
  -- Con tope de tamaño: sin él, alguien con la clave del juego podría subir
  -- textos enormes y llenar los 500 MB del plan gratis (revisión del 05/11).
  personaje text not null check (char_length(personaje) <= 20),
  dificultad text not null check (dificultad in ('facil', 'media', 'dificil')),
  donde text check (char_length(donde) <= 40),
  version text check (char_length(version) <= 16),
  -- La misma partida no se guarda dos veces: si se pierde la respuesta del
  -- servidor, el juego la vuelve a mandar y recibe un 409.
  unique (usuario, jugada)
);

-- Seguridad por filas (RLS): sin una regla que lo permita, nadie puede nada.
alter table public.perfiles enable row level security;
alter table public.partidas enable row level security;

-- Los nombres y las partidas los puede leer cualquiera (para el ranking).
create policy "leer perfiles" on public.perfiles for select using (true);
create policy "leer partidas" on public.partidas for select using (true);
-- Cada uno solo puede añadir partidas suyas. No hay reglas para cambiarlas
-- ni borrarlas: una partida subida ya no se toca.
create policy "añadir mis partidas" on public.partidas for insert
  to authenticated with check (usuario = (select auth.uid()));

-- Al crear una cuenta, su perfil, con el nombre que manda el juego. El email
-- tiene que ser el que sale del nombre (como lo hace el juego): si no, con la
-- API alguien podría ocupar dos nombres con una cuenta (revisión del 05/11).
create function public.crear_perfil() returns trigger
  language plpgsql security definer set search_path = '' as $$
begin
  if new.email is distinct from lower(new.raw_user_meta_data ->> 'nombre') || '@sectorcero.app' then
    raise exception 'el email no corresponde al nombre';
  end if;
  insert into public.perfiles (id, nombre)
  values (new.id, new.raw_user_meta_data ->> 'nombre');
  return new;
end;
$$;
create trigger al_crear_cuenta after insert on auth.users
  for each row execute function public.crear_perfil();

-- Los récords y las estadísticas de cada jugador, calculados de sus
-- partidas (no se guardan aparte: así nunca se contradicen).
create view public.estadisticas with (security_invoker = true) as
select usuario,
  count(*) as partidas,
  count(*) filter (where victoria) as victorias,
  max(tiempo) as mejor_tiempo,
  max(nivel) as mejor_nivel,
  max(eliminados) as mas_eliminados
from public.partidas
group by usuario;

-- Las opciones del jugador (volumen, CRT, texto grande...), para tenerlas
-- igual en cualquier ordenador donde entre. Solo las suyas.
create table public.opciones (
  usuario uuid primary key default auth.uid() references public.perfiles (id) on delete cascade,
  -- Unas pocas opciones ocupan menos de 1 KB: 4 KB de tope sobra.
  datos jsonb not null default '{}' check (pg_column_size(datos) < 4096),
  actualizado timestamptz not null default now()
);
alter table public.opciones enable row level security;
create policy "leer mis opciones" on public.opciones for select
  to authenticated using (usuario = (select auth.uid()));
create policy "crear mis opciones" on public.opciones for insert
  to authenticated with check (usuario = (select auth.uid()));
create policy "cambiar mis opciones" on public.opciones for update
  to authenticated using (usuario = (select auth.uid()))
  with check (usuario = (select auth.uid()));

-- Para las skins, más adelante: lo que tiene cada jugador. Se puede leer
-- lo propio, pero no hay regla para añadir: las skins solo las podrá dar el
-- servidor (una Edge Function), para que no se puedan trucar desde el juego.
create table public.inventario (
  usuario uuid not null references public.perfiles (id) on delete cascade,
  objeto text not null,
  conseguido timestamptz not null default now(),
  primary key (usuario, objeto)
);
alter table public.inventario enable row level security;
create policy "leer mi inventario" on public.inventario for select
  to authenticated using (usuario = (select auth.uid()));

-- Permisos. Son dos candados: el permiso dice qué se puede hacer con la
-- tabla y la regla RLS, con qué filas. Supabase da todos los permisos a anon
-- (sin cuenta) y authenticated (con cuenta), TRUNCATE incluido, que se salta
-- el RLS: se quitan todos y se dan solo los que usa el juego.
revoke all on public.perfiles, public.partidas, public.estadisticas, public.opciones, public.inventario from anon, authenticated;
grant select on public.perfiles, public.partidas, public.estadisticas to anon, authenticated;
grant insert on public.partidas to authenticated;
grant select, insert, update on public.opciones to authenticated;
grant select on public.inventario to authenticated;
-- La función del perfil solo la usa el trigger: nadie la puede llamar.
revoke execute on function public.crear_perfil() from public, anon, authenticated;
-- La que crea «Enable automatic RLS» al hacer el proyecto, lo mismo (aviso
-- de seguridad de Supabase del 05/11). En un proyecto sin esa casilla no
-- existe: quitar esta línea.
revoke execute on function public.rls_auto_enable() from public, anon, authenticated;
```

## Paso 3: en el juego (lo hace Claude)

**Scripts nuevos**, sin `class_name` y sin tocar `project.godot` (como el
mando): no hace falta subir `EJECUTABLE_MINIMO`.

- `globales/cuenta.gd`, creado al arrancar como `entrada.gd`:
  - **crear cuenta**: `POST /auth/v1/signup` con
    `{"email": "<usuario en minúsculas>@sectorcero.app", "password": …,
    "data": {"nombre": …}}`
  - **entrar**: `POST /auth/v1/token?grant_type=password`
  - **renovar la sesión** al arrancar: `grant_type=refresh_token`
  - **subir una partida**: `POST /rest/v1/partidas`, con la cabecera `apikey`
    (la clave publicable) y `Authorization: Bearer <token del jugador>`
  - **cola sin conexión**: si no hay internet, la partida espera en
    `user://partidas_pendientes.cfg` y se sube al volver
  - guarda en `user://cuenta.cfg` el nombre y el token de renovación, **nunca
    la contraseña**
  - avisa por el bus con una señal nueva, `sesion_cambiada(nombre)` (vacío
    si es invitado)
- `escenas/interfaz/panel_cuenta.gd`: ventana del menú con usuario,
  contraseña (oculta), ENTRAR, CREAR CUENTA y JUGAR COMO INVITADO, y los
  errores en castellano («ese nombre ya existe», «contraseña incorrecta», «sin
  conexión: se juega como invitado»).
- En el menú: arriba, «Invitado» o el nombre de la cuenta, con un botón
  CUENTA. Más adelante, una pestaña **MUNDIAL** en el ranking y **MIS
  PARTIDAS**.

**Detalles a tener en cuenta:**
- **Con mando** no se puede escribir (en PC no hay teclado en pantalla): la
  cuenta se crea o se abre con teclado. Después, la sesión se recuerda y con
  el mando ya se juega con ella.
- **La web** (GitHub Pages) puede hablar con Supabase igual.
- El dominio del email (`@sectorcero.app`) es inventado: no se manda ningún
  correo porque la confirmación está apagada. Probarlo el primer día; si
  Supabase lo rechazara, se cambia por otro.
- Los endpoints, comprobarlos con la documentación oficial al programarlo
  (las claves de Supabase cambiaron en 2025).

## Fases y tiempo

| Fase | Quién | Qué | Tiempo |
|---|---|---|---|
| 1 | Adam | Crear el proyecto y pegar el SQL | 15 min |
| 2 | Claude | `cuenta.gd`, el panel de cuenta y la sesión recordada | 1 sesión |
| 3 | Claude | Subir las partidas, la cola sin conexión y MIS PARTIDAS | 1 sesión |
| 4 | Claude | Ranking mundial (opcional) | ½ sesión |
| Futuro | — | Logros, pase de batalla y skins | Sin concretar |

**Para el futuro:** los logros serían una tabla `logros` (la lista) y otra
`logros_conseguidos` (usuario, logro, fecha); las skins, una tabla
`inventario`. Si dan algo de valor, se tendrían que dar desde el servidor
(una Edge Function de Supabase) y no desde el juego, porque el juego se
puede trucar.

## Riesgos

- **Pausa a los 7 días.** Un proyecto gratis sin actividad durante una semana
  se pausa (no pierde datos). Pasó entre el 05 y el 13/11: Claude lo
  reactivó con el conector. Desde el 13/11 la Action
  `.github/workflows/despertar_supabase.yml` le hace una consulta los lunes
  y los jueves para que no se pause (si sale en rojo, GitHub avisa por
  correo y hay que reactivarlo a mano). **Antes de la defensa, entrar al panel de
  Supabase y comprobar que está activo.** El juego tiene que seguir yendo
  como invitado si el servidor no responde.
- **Trampas.** Las partidas las manda el propio juego: quien sepa podría
  subir una falsa. Para el proyecto basta; si un día hay premios, validar en
  el servidor.
- **Privacidad.** Sin email, el único dato es el nombre. Para borrar una
  cuenta, de momento se borra desde el panel de Supabase (borra también sus
  partidas, por el `on delete cascade`).
- **Claves antiguas.** Supabase retira `anon` y `service_role` a finales de
  2026: usar ya la clave publicable.

## Qué contar al tribunal

Una arquitectura cliente-servidor sin servidor propio: Supabase pone la base
de datos (Postgres) y la autenticación. La seguridad no depende de esconder
la clave del juego, sino de las reglas por filas (RLS): cualquiera puede
leer el ranking, pero solo puedes añadir partidas a tu cuenta, y nadie puede
cambiarlas. El juego sigue funcionando sin conexión.

## Preguntas abiertas para Adam y Alan

1. ¿Iniciar sesión opcional (con invitado) o obligatorio?
2. ¿Ranking mundial en esta tanda o más adelante?
3. ¿Quién lleva esta parte: Adam o Alan? (Alan tendrá Claude Pro; ver el
   reparto pendiente en `requisitos_y_estado.md`.)

## Fuentes

- [Supabase: claves de la API (publicable y secreta)](https://supabase.com/docs/guides/api/api-keys)
- [Supabase: pasar a las claves nuevas](https://supabase.com/docs/guides/getting-started/migrating-to-new-api-keys.md)
- [Supabase: pausa de los proyectos gratis](https://supabase.com/kb/faqs/platform/free-project-pausing)
