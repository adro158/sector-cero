# Manual de usuario — Sector Cero

## Objetivo

Eres un antivirus dentro de un ordenador infectado. **Aguanta 10 minutos**
contra el malware, **derrota al jefe**, sobrevive a la **fase 2** y, a los 15
minutos, **derrota a NÚCLEO CERO**, el jefe final, para ganar. Si tu
integridad (la barra sobre tu personaje) llega a cero, pierdes.

## Instalar y abrir

El juego se juega con el **lanzador**. Descarga de la última versión de
[Releases](https://github.com/adro158/sector-cero/releases) el instalador:
en Windows, `SectorCero_Instalador_vX.exe` (Siguiente, la carpeta y
Finalizar; si Windows avisa de que no es de un editor conocido, **Más
información** y **Ejecutar de todas formas**); en Linux,
`SectorCero_Lanzador_linux_vX.zip`, que se descomprime para abrir
`SectorCero_Lanzador.x86_64` (si no arranca, `chmod +x` a los dos
ejecutables). En el lanzador, elige la versión en el desplegable (se
descarga en un momento) y pulsa **JUGAR**; al cerrar el juego vuelves al
lanzador. Las versiones nuevas aparecen solas y el lanzador se actualiza
solo. Sin descargar nada, la última versión se juega también en el
navegador, en [adro158.github.io/sector-cero](https://adro158.github.io/sector-cero/).

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

Antes de jugar, elige la **dificultad** en el menú principal (se queda
guardada para la próxima vez):

- **Fácil:** comparado con la media, el malware hace un 30 % menos de daño y
  tiene algo menos de vida, y cuando llega el jefe huye toda la horda.
- **Media:** la partida como la hemos equilibrado. Cuando llega el jefe, huye
  la mitad de la horda.
- **Difícil:** la horda tiene un 40 % más de vida, el malware hace un 20 %
  más de daño que en media y cuando llega el jefe no huye nadie. Kernel
  Panic tiene algo menos de vida que en media: llegas a él con toda la horda
  encima.

1. **Solo te mueves.** Tu herramienta ataca sola; tú decides dónde colocarte.
2. **Recoge los fragmentos de datos** que suelta el malware (amarillos,
   naranjas o magentas según lo que valen). A los 30 segundos parpadean y se
   pierden.
3. **Al subir de nivel** el juego se pausa y eliges una de tres mejoras. Las
   que llevas salen en la columna de la izquierda, con su nivel en puntos; las
   evoluciones (las de un personaje), arriba del todo y de su color. Cada
   nivel cuesta más, y los enemigos ganan vida con cada nivel que subes y, desde
   el minuto 3, con cada minuto que pasa.
4. **El malware se adapta.** Cada 20 segundos se hace más resistente a la
   herramienta que más le ha dañado: tus números de daño se vuelven rojos.
5. **Cambia de personaje** para atacarle con otra herramienta (10 s de espera
   entre cambios). Cada uno tiene su propia vida y los que esperan se curan
   poco a poco. Si cae el que llevas, el juego se pausa y eliges quién sigue;
   pierdes cuando caen los tres:
   - **Espadachín · Firewall (120 de vida):** da tajos en un cono hacia donde
     vas (el contorno verde): cuanto más pegado está el malware, más daño (el
     triple que en el filo), y lo de detrás no lo toca. Cada golpe le cura un
     poco (robo de vida). Evolucionado llega más lejos y pega igual en todo
     el cono.
   - **Mago · Ping (90 de vida):** un paquete que salta de un enemigo a otro, a
     distancia.
   - **Segador · Escáner (100 de vida):** un pulso fuerte y amplio, pero lento.
   Cada uno carga su **ulti** matando (la barra amarilla bajo su vida); llena,
   se lanza con **R**: el Mago dispara un rayo morado (con R apuntas con el
   ratón y con click lo lanzas), el Espadachín gira con sus hojas y al Segador
   le cae una tormenta de rayos.
6. **Evoluciones.** Elige tres veces la misma mejora de daño, cadencia o
   alcance y tu herramienta evoluciona.
7. **Cuidado con:** el **troyano** (caballo verde), que parpadea en rojo y
   embiste en línea recta (apártate de lado), y el **ransomware** (candado
   rojo), lento pero muy duro.
8. **Élites.** Cada minuto llega uno con habilidades escritas encima
   (blindado, replicante, aura lenta o explosivo), y cada una se ve: placas
   de armadura, copias fantasma, un anillo helado que te ralentiza si estás
   dentro, o un anillo naranja si va a explotar al morir. Al matarlo deja un
   **corazón**, que cura la mitad de la vida, y un **cofre**: al recogerlo gira
   una ruleta y te llevas la mejora que toque. Hay que ir a por ellos.
9. **El jefe, KERNEL PANIC,** llega a los 10 minutos y ya no sale más horda (en fácil huye
   toda la que queda, y en media, la mitad); el reloj se para mientras está y su
   vida sale arriba en el centro. Baja en una columna de datos y no ataca hasta
   que ha acabado de aparecer. Cuando se pone rojo, va a
   embestir: apártate. Cuando late en morado, va a sacar un anillo de malware
   o a disparar una ráfaga en círculo (pasa por los huecos). Si marca un
   anillo rojo en el suelo, va a pisar y dejar una jaula: sal antes o te
   quedarás encerrado con él. Al bajarle al 66 % y al 33 % de vida se
   enfurece (lo avisa la pantalla): va más rápido, pega más, ataca más
   seguido y saca más malware. En la última furia, arde.
10. **Fase 2.** Al derrotarlo, el sector se reinicia (los personajes caídos
    vuelven con la mitad de su vida) y queda dañado: vuelve la horda, más
    dura, hasta los 15 minutos. Entonces llega **NÚCLEO CERO** (su vida, arriba
    en el centro). Al bajarle al 66 % y al 33 % cambia de forma y es más duro.
    Te ataca con un rayo (flechas rojas), un torbellino (anillo a su
    alrededor), una tormenta (dianas en el suelo), portales de malware y
    cristales que dejan hielo, que te ralentiza: todos avisan antes. Al cambiar
    de forma se encierra en un escudo: **rompe las cuatro anclas** y se quedará
    aturdido, recibiendo más daño. Cada ancla es del color de un personaje y
    solo la rompe su herramienta (un 0 rojo es que no le haces nada): cambia
    de personaje, que con el escudo puesto se hace sin espera. Si pasan 30 s
    sin que rompas ninguna, las rotas se cierran.

Haz click en cualquier enemigo para ver su vida, su daño y cuánto resiste a tu
herramienta.

## Pantallas

- **Menú:** dificultad, jugar, reglas (qué hace cada personaje, mejora y
  enemigo), ranking, opciones y salir.
- **Ranking:** las 10 mejores partidas del ordenador, con la dificultad de
  cada una. Si tu partida entra, al acabar te pide un nombre.
- **Opciones:** volumen, pantalla completa y filtro CRT. Se guardan solas.
- **Resultados:** tiempo, nivel, malware eliminado y dificultad, y si has
  batido un récord.
