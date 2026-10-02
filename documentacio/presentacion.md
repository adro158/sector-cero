# Presentación y defensa — Sector Cero

Guion para la presentación ante los "inversores" y preparación de las preguntas
del tribunal. El enunciado pide explicar: la idea, qué se ha construido, la
mecánica principal, las decisiones técnicas, el problema técnico más difícil,
qué diferencia al proyecto, qué se mejoraría con más tiempo y una demostración.

## Guion (unos 6-8 minutos)

### 1. La idea (30 s)

"El malware real evoluciona para esquivar los antivirus que más se usan.
Nosotros lo hemos convertido en un juego: Sector Cero es un *survivors-like*
donde eres un antivirus y el malware aprende a resistir la herramienta con la
que más le pegas."

### 2. Qué hemos construido (1 min)

Un juego completo de 10 minutos más un jefe, para Windows y Linux, con:
menú con récords y opciones, partida, pausa y resultados; tres personajes;
evoluciones; élites con afijos al azar; jefe final; mapa infinito; música y
efectos propios; y un filtro CRT que da la estética de monitor antiguo.

### 3. La mecánica principal (1 min)

Solo te mueves; la herramienta ataca sola. Decides dos cosas: **dónde te
colocas** y **qué mejora eliges**. Y, por el elemento diferencial, **cuándo
cambias de personaje**.

### 4. Demostración (2-3 min)

1. Menú: enseñar las reglas y las opciones (bajar la música, quitar y poner el
   CRT).
2. Empezar partida. Moverse entre la horda; enseñar los números de daño.
3. Subir de nivel y elegir mejora con las teclas 1-2-3.
4. Pulsar **F3**: el panel técnico enseña la resistencia del malware subiendo.
   Cuando los números salgan rojos, cambiar de personaje con **Q** y ver que
   vuelven a salir blancos.
5. Esperar al primer élite (1:30): leer sus afijos sobre la cabeza.
6. Pausa con Esc y volver al menú. Enseñar que el récord se ha guardado.

Si el tiempo es corto, tener preparado el vídeo para enseñar el jefe.

### 5. Decisiones técnicas (1 min)

- **Un enemigo no es un nodo.** Arrays y un MultiMesh por tipo: cientos de
  enemigos con una llamada de dibujado.
- **Rejilla espacial propia** para no comparar cada enemigo con todos.
- **Datos en recursos `.tres`:** un arma nueva es un fichero, no código.
- **Un bus de señales** como única frontera entre sistemas.
- **Audio generado por código:** propio y sin licencias.

### 6. El problema más difícil (1 min)

Los índices caducados de la rejilla espacial (ver la documentación técnica): un
fallo sin ningún error, solo golpes que no hacían daño, que apareció al cambiar
el orden de dos operaciones. Lo encontramos con una prueba dirigida y aprendimos
que una prueba también tiene que demostrar que detecta el fallo: la primera
versión de la prueba pasaba incluso con el código roto.

### 7. Qué nos diferencia (30 s)

La resistencia adaptativa convierte el problema típico del género (encontrar el
arma más fuerte y repetirla) en una decisión: cuándo cambiar de herramienta. Y
la mejora Actualizar firmas añade otra: gastar un nivel en frenar la adaptación
en vez de en más daño.

### 8. Qué mejoraríamos (30 s)

Pixel art propio para los personajes, un jefe intermedio y controles
remapeables.

## Preguntas probables del tribunal

**¿Por qué los enemigos no son nodos?**
Porque cada nodo se procesa y se dibuja por separado. Con cientos de enemigos
serían cientos de llamadas de dibujado. Con un MultiMesh por tipo hay una sola.
El enemigo es una posición y una vida en dos arrays.

**¿Qué pasa cuando muere un enemigo en mitad del array?**
El último vivo pasa a ocupar su hueco (`_eliminar` en `gestor_enemigos.gd`).
Así los vivos están siempre al principio y se dibujan con
`visible_instance_count`. Los recorridos que eliminan van hacia atrás porque el
que llega al hueco ya se ha comprobado.

**¿Cómo funciona la rejilla espacial?**
`rejilla_espacial.gd`: divide el mapa en celdas del tamaño del radio de
separación y guarda qué enemigos hay en cada celda. Para buscar cerca de un
punto solo se miran las celdas que cubren el radio. Se reconstruye entera cada
fotograma porque todos se mueven a la vez.

**¿Por qué las mejoras no cambian el `.tres` del arma?**
Porque Godot comparte los recursos cargados y los guarda en caché: el cambio se
quedaría para la siguiente partida. Por eso las mejoras son multiplicadores en
el nodo al que afectan: `gestor_armas.gd` para daño, cadencia y alcance, y
`resistencia_malware.gd`, `cambio_personaje.gd` o `pool_gemas.gd` para las
tres nuevas. Todas pasan por el `match` de `sistema_niveles.gd`.

**¿Cómo se guarda el récord? ¿Dónde?**
`gestor_guardado.gd` escucha `partida_terminada` y guarda en un `ConfigFile`
en `user://sector_cero.cfg` (en Windows, `%APPDATA%/Godot/app_userdata/Sector
Cero`). No se puede guardar en `res://` porque dentro del ejecutable es de solo
lectura.

**¿De dónde sale el audio?**
`herramientas/generar_audio.gd` suma ondas (cuadrada, triángulo, sierra, seno,
ruido) con una envolvente de volumen. La música es una secuencia de notas por
pasos. Se ejecuta una vez y guarda los WAV.

**¿Cómo funciona el mapa infinito?**
`arena.gd` mueve el rectángulo del suelo bajo la cámara en cada fotograma, y el
shader dibuja con la posición del mundo (`MODEL_MATRIX * VERTEX`), no con la del
rectángulo: el dibujo se queda quieto aunque el rectángulo se mueva.

**¿Cómo está hecho el suelo de placa base?**
`suelo.gdshader` parte el mundo en casillas de 256x256. Cada casilla saca un
número al azar con su posición (`azar(casilla)`: siempre el mismo para la
misma casilla) y con él elige uno de los 12 dibujos del atlas
`suelo_placa.png`. Los 12 tienen las pistas del borde en los mismos sitios, así
que encajan en cualquier orden. Dos texturas más no son dibujo sino datos: la
máscara dice qué píxeles son pistas con datos (rojo), cuánto camino llevan
(verde) y si van en horizontal o vertical (azul); el shader enciende el píxel
cuyo camino coincide con `avance_pulsos`, y así parece que un pulso viaja. La
de efectos marca LEDs, aspas y brillo de chips, que se animan con `TIME`.
`arena.gd` suma `avance_pulsos` cada fotograma: si lo hiciera el shader con
`TIME`, al cambiar la velocidad los pulsos saltarían de sitio. Escucha
`tiempo_partida` para acelerarlos y `jefe_aparecio` para ponerlos en rojo con
un tween, y trabaja con una copia del material para que el rojo no se quede
en la partida siguiente.

**¿Qué hace el shader de la horda?**
`horda.gdshader`: el destello al recibir daño llega por enemigo en
`INSTANCE_CUSTOM.r`, que el gestor rellena, y el aviso del troyano en
`INSTANCE_CUSTOM.g`, que lo hace parpadear en rojo; el glitch es un número al
azar por enemigo (`INSTANCE_ID`) y por instante de tiempo que, si supera un
umbral, desplaza el enemigo y separa sus colores.

**¿Cómo embiste el troyano si no es un nodo?**
Igual que el jefe, con tres estados: perseguir, aviso y embestida. Pero el
jefe es un nodo y guarda su estado en variables; un troyano es solo un índice
en los arrays del gestor, así que su estado, su cronómetro y su dirección van
en tres arrays más del mismo tamaño (`embestida_horda.gd`). Al morir otro, se
copian con él a su nuevo hueco (`copiar` desde `_eliminar`). Está en un script
aparte para que el gestor no crezca y solo lo crean los tipos con `embiste`.

**¿Por qué solo hay ocho ransomware a la vez?**
El director elige el tipo al azar entre los disponibles: sin límite salían unos
250 por partida, lentos y con mucha vida, que se acumulaban detrás del jugador,
y el bot pasaba de ganar 4 de 5 a 1 de 5. `maximo_vivos` en su `.tres` y
`cabe_otro()` en el gestor: si ya hay ocho, ese turno sale otro tipo.

**¿Cómo decide el malware a qué resistir?**
`resistencia_malware.gd`: las armas le avisan del daño que hacen. Cada 20 s
mira cuál ha hecho más, le sube la resistencia un 10 % (máximo 50 %) y baja la
de las demás un 5 %. La mejora Actualizar firmas multiplica ese 10 % por 0,7
cada vez que se elige (`_resistencia.aumento *= 1.0 - mejora.valor`), igual
que la cadencia: nunca llega a cero.

**¿Por qué los élites y el jefe están en la escena desde el principio?**
Las armas buscan sus objetivos (el grupo `objetivos`) al empezar la partida. Si
se crearan después, no los verían. Están ocultos e inactivos hasta que el
director los activa; además, así se reutilizan.

**¿Cómo habéis usado la IA?**
Claude como asistente de programación: escribir código, proponer alternativas,
encontrar errores, escribir pruebas y redactar documentación. Las decisiones las
tomamos nosotros y nada se dio por bueno sin ejecutarlo. Los sprites de los
personajes y del jefe: a partir del ejemplo del profesor, la idea con Gemini y
las hojas de sprites con Claude. Los de la horda, tres iconos y el suelo, con
Claude en una conversación aparte; después se integraron y se probaron aquí.

**Cambia esto en directo:** prepararse para cambios pequeños que pueden pedir,
por ejemplo:
- Que la partida dure 5 minutos: `duracion_partida` en
  `recursos/oleadas/datos/config_principal.tres`.
- Más daño para el Firewall: `dano` en `recursos/armas/datos/firewall.tres`.
- Que el malware resista más rápido: `intervalo_analisis` o `aumento` en el nodo
  `ResistenciaMalware` de `raiz_juego.tscn`.
- Otro afijo: crear un `.tres` de `DatosAfijoElite` y añadir su efecto en
  `enemigo_elite.gd`.
- Más ransomware a la vez: `maximo_vivos` en
  `recursos/enemigos/datos/ransomware.tres`.
- Que el troyano avise más tiempo o embista desde más lejos: `duracion_aviso` o
  `distancia_embestida` en `recursos/enemigos/datos/troyano.tres`.
- Que otro enemigo embista: `embiste = true` en su `.tres`.
