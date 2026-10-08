# Manual de usuario — Sector Cero

## Objetivo

Eres un antivirus dentro de un ordenador infectado. **Aguanta 10 minutos**
contra el malware y **derrota al jefe final** para ganar. Si tu integridad (la
barra sobre tu personaje) llega a cero, pierdes.

## Instalar y abrir

Descarga el `.zip` de [Releases](https://github.com/adro158/sector-cero/releases),
descomprímelo y abre `SectorCero.exe` (en Linux, `SectorCero.x86_64`; si no
arranca, dale permiso con `chmod +x SectorCero.x86_64`). No hay que instalar
nada. Si sale una versión nueva, el juego avisa solo (también en plena
partida): **ACTUALIZAR** la descarga y reinicia el juego, y **AHORA NO** lo deja
para más tarde, con el botón en el menú. Con **VERSIONES** se puede
instalar cualquier versión publicada, también una anterior; en Opciones se
puede apagar el aviso.

## Controles

| Acción | Teclado | Mando |
|---|---|---|
| Moverse | WASD o flechas | Stick izquierdo |
| Personaje siguiente / anterior | E o Tab / Q | Y / — |
| Ver el equipo (vida de cada personaje) | C | — |
| Lanzar la ulti (cuando está cargada) | R | B |
| Pausa | Esc o P | Start |
| Elegir mejora | 1, 2, 3 o click | Cruceta y A |
| Ficha de un enemigo | Click (click derecho la cierra) | — |
| Empezar / reintentar | Enter | A |
| Panel técnico | F3 | — |
| Menú de desarrollador (la partida deja de contar) | F1 | — |

## Cómo se juega

1. **Solo te mueves.** Tu herramienta ataca sola; tú decides dónde colocarte.
2. **Recoge los fragmentos de datos** que suelta el malware (amarillos,
   naranjas o magentas según lo que valen). A los 30 segundos parpadean y se
   pierden.
3. **Al subir de nivel** el juego se pausa y eliges una de tres mejoras. Cada
   nivel cuesta más, y los enemigos ganan vida con cada nivel que subes y, desde
   el minuto 3, con cada minuto que pasa.
4. **El malware se adapta.** Cada 20 segundos se hace más resistente a la
   herramienta que más le ha dañado: tus números de daño se vuelven rojos.
5. **Cambia de personaje** para atacarle con otra herramienta (10 s de espera
   entre cambios). Cada uno tiene su propia vida y los que esperan se curan
   poco a poco. Si cae el que llevas, el juego se pausa y eliges quién sigue;
   pierdes cuando caen los tres:
   - **Espadachín · Firewall (120 de vida):** golpea todo lo que tienes alrededor.
   - **Mago · Ping (90 de vida):** un paquete que salta de un enemigo a otro, a
     distancia.
   - **Segador · Escáner (100 de vida):** un pulso fuerte y amplio, pero lento.
   Cada uno carga su **ulti** matando (la barra amarilla bajo su vida); llena,
   se lanza con **R**: el Mago dispara un rayo morado, el Espadachín gira con
   sus hojas y al Segador le cae una tormenta de rayos.
6. **Evoluciones.** Elige tres veces la misma mejora de daño, cadencia o
   alcance y tu herramienta evoluciona.
7. **Cuidado con:** el **troyano** (caballo verde), que parpadea en rojo y
   embiste en línea recta (apártate de lado), y el **ransomware** (candado
   rojo), lento pero muy duro.
8. **Élites.** Cada minuto llega uno con habilidades escritas encima
   (blindado, replicante, aura lenta o explosivo). Al matarlo deja un
   **corazón**, que cura la mitad de la vida, y un **cofre**: al recogerlo gira
   una ruleta y te llevas la mejora que toque. Hay que ir a por ellos.
9. **El jefe final** llega a los 10 minutos y la horda huye. Cuando se pone
   rojo, va a embestir: apártate. Cuando late en morado, va a sacar un anillo
   de malware a su alrededor.

Haz click en cualquier enemigo para ver su vida, su daño y cuánto resiste a tu
herramienta.

## Pantallas

- **Menú:** jugar, reglas (qué hace cada personaje, mejora y enemigo),
  ranking, opciones y salir.
- **Ranking:** las 10 mejores partidas del ordenador. Si tu partida entra, al
  acabar te pide un nombre.
- **Opciones:** volumen, pantalla completa y filtro CRT. Se guardan solas.
- **Resultados:** tiempo, nivel y malware eliminado, y si has batido un récord.
