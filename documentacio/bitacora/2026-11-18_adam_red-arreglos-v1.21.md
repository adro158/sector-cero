# 18/11/2026 — Adam — Arreglos de la partida en red tras probarla, y v1.21

**Participantes:** Adam (con Claude Code). **Duración:** sin apuntar, como
la otra entrada de hoy (`2026-11-18_adam_red-interfaz.md`): las horas del
18/11 van en la entrada del 19/11. **Horas acumuladas:** 55 h, sin cambios.

## Qué se ha hecho

Adam probó la v1.20 en red con Alan y pidió: «Empieza por los más fácil y
arregla todos los errores estos». Todo en la rama `adam/red-arreglos`.

1. **Al compañero seguía sin subirle la resistencia.** Ya llegaba bien del
   anfitrión (v1.20), pero el malware solo se adaptaba a la herramienta que
   más daño hacía entre todos: la del otro jugador casi nunca ganaba. Ahora
   sube las N más usadas, con N el número de jugadores
   (`resistencia_malware.gd`, `_mas_usadas`). Solo es una, como siempre.
2. **La ulti salía mal.** La barra de encima de cada personaje
   (`barra_vida.gd`) escuchaba `ulti_cambiada`, que trae la carga del
   jugador de este ordenador: encima del compañero salía la tuya. Ahora:
   - la carga es del personaje y vive en el equipo (`equipo.gd`, `cargas`),
     que comparten todos
   - cada barra lee la de su jugador (`Ultis.fraccion()`)
   - en red viaja con el equipo en el estado (clave `e`)
   - Adam: «que todos puedan ver el porcentaje de ulti de las otras
     personas».
3. **La ruleta del cofre del compañero**, en grande y con el mensaje. La
   pequeña giraba sin la animación del cofre, así que acababa antes que la
   del que lo abría y le chafaba el premio. Ahora `ruleta_companero.gd` hereda
   de `panel_ruleta.gd`: es la misma ruleta, con el mismo tiempo, sin
   aceptar y con «ALAN ESTÁ ABRIENDO UN COFRE» en su color. Se cierra cuando
   se aplica su premio, y mientras se ve no sale el aviso de espera.
4. **Los tirones de los enemigos en el cliente.** La horda solo cambiaba de
   sitio con cada estado (20 por segundo). Ahora:
   - el anfitrión manda el id de cada enemigo y su paso de física
   - el cliente saca la velocidad de cada uno y lo hace seguir andando
     hasta el siguiente estado (`gestor_enemigos.gd`)
   - si dejan de llegar estados (el anfitrión parado), la horda se para a
     los 0,15 s
5. **El estado va comprimido** (`red.gd`, DEFLATE), y ocupa la mitad. La
   prueba avisó de que pasaba de la MTU (1392 bytes): ENet lo partía y, si
   se perdía un trozo, se perdía el estado entero. Medido:
   - sin horda: 1296 → 224 bytes
   - con 50 enemigos cerca: 1936 → 689
   - con 150: 3216 → 1493
6. **La derrota con el compañero cayendo el último** («la animación ha sido
   como muy rara»). Al caer el último, el anfitrión se para y deja de mandar
   estados. En los demás todo se quedaba congelado, con él de pie, hasta la
   pantalla final. Ahora el anfitrión manda el suceso «derrota» y los
   clientes se paran y lo deshacen con la animación de la derrota
   (`cambio_personaje.gd`, `caer_el_ultimo`).

## Decisiones técnicas y por qué

- **La carga de la ulti es del personaje y no del jugador**: el equipo ya es
  compartido (vida, caídos), y así todos ven la misma.
- **Sin interpolar con retraso**: el cliente sigue con la velocidad, para no
  ver la horda más atrás de donde está. El tiempo entre estados es el del
  anfitrión (sus pasos de física) y no el de llegada, que varía con la red.
- **Solo el estado va comprimido**: los demás mensajes son pequeños, y el
  saludo tiene que entenderse entre versiones para poder rechazar la que no
  toca.

## Uso de IA y métodos de test

- Claude Code programó y probó.
- Con dos copias en red:
  - suben las resistencias de los dos
  - la barra de cada uno con su carga
  - la ruleta grande, que se abre y se cierra al aceptar
  - la horda con velocidad en el cliente
  - la derrota en el cliente, con su animación y su pantalla final
- Capturas con ventana de la ruleta del compañero y de la derrota en el
  cliente.
- `/validar` y simulador de 3 partidas: la primera da lo mismo que antes
  (1142 s y 5743 eliminados). Siguen 16 clases.

## Estado al cerrar y siguiente paso

- Publicada la v1.21 con estos arreglos.
- **Siguiente:** probarla con dos ordenadores en clase (issue #15). En el
  cliente, los élites y los jefes aún se mueven a saltos de 20 por segundo.
  Se nota menos que en la horda, pero se puede hacer lo mismo.
