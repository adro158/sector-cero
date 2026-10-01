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
arma más fuerte y repetirla) en una decisión: cuándo cambiar de herramienta.

### 8. Qué mejoraríamos (30 s)

Pixel art propio para los personajes, más tipos de horda y un jefe intermedio,
y controles remapeables.

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
`gestor_armas.gd`.

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

**¿Qué hace el shader de la horda?**
`horda.gdshader`: el destello al recibir daño llega por enemigo en
`INSTANCE_CUSTOM`, que el gestor rellena; el glitch es un número al azar por
enemigo (`INSTANCE_ID`) y por instante de tiempo que, si supera un umbral,
desplaza el enemigo y separa sus colores.

**¿Cómo decide el malware a qué resistir?**
`resistencia_malware.gd`: las armas le avisan del daño que hacen. Cada 20 s
mira cuál ha hecho más, le sube la resistencia un 10 % (máximo 50 %) y baja la
de las demás un 5 %.

**¿Por qué los élites y el jefe están en la escena desde el principio?**
Las armas buscan sus objetivos (el grupo `objetivos`) al empezar la partida. Si
se crearan después, no los verían. Están ocultos e inactivos hasta que el
director los activa; además, así se reutilizan.

**¿Cómo habéis usado la IA?**
Claude como asistente de programación: escribir código, proponer alternativas,
encontrar errores, escribir pruebas y redactar documentación. Las decisiones las
tomamos nosotros y nada se dio por bueno sin ejecutarlo. Los sprites de los
personajes y del jefe: a partir del ejemplo del profesor, la idea con Gemini y
las hojas de sprites con Claude.

**Cambia esto en directo:** prepararse para cambios pequeños que pueden pedir,
por ejemplo:
- Que la partida dure 5 minutos: `duracion_partida` en
  `recursos/oleadas/datos/config_principal.tres`.
- Más daño para el Firewall: `dano` en `recursos/armas/datos/firewall.tres`.
- Que el malware resista más rápido: `intervalo_analisis` o `aumento` en el nodo
  `ResistenciaMalware` de `raiz_juego.tscn`.
- Otro afijo: crear un `.tres` de `DatosAfijoElite` y añadir su efecto en
  `enemigo_elite.gd`.
