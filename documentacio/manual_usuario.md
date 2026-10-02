# Manual de usuario — Sector Cero

## Objetivo

Eres un proceso antivirus dentro de un ordenador infectado. Oleadas de malware
vienen hacia ti desde todas partes. **Aguanta 10 minutos** y aparecerá el jefe
final: **derrótalo para ganar**. Si tu integridad (la barra de vida sobre tu
personaje) llega a cero, pierdes.

## Cómo arrancar el juego

- **Windows:** descomprime el `.zip` y abre `SectorCero.exe`.
- **Linux:** descomprime y ejecuta `SectorCero.x86_64` (si hace falta, dale
  permiso de ejecución con `chmod +x SectorCero.x86_64`).

No hace falta instalar nada ni abrir Godot.

**Actualizaciones:** al abrir el juego, debajo de los botones del menú aparece
la versión. Si hay una nueva, aparece el botón **ACTUALIZAR**: la descarga y
reinicia el juego. Sin conexión a internet el juego funciona igual.

## Controles

| Acción | Teclado | Mando |
|---|---|---|
| Moverse | WASD o flechas | Stick izquierdo |
| Cambiar de personaje | Q o Tab | Y |
| Pausa | Esc o P | Start |
| Elegir mejora | 1, 2, 3 o click | Cruceta y A |
| Empezar / reintentar | Enter | A |
| Panel técnico | F3 | — |

Los menús también se usan con el ratón.

## Cómo se juega

1. **Solo te mueves.** Tu herramienta ataca sola cada pocos segundos. Tu
   decisión es dónde colocarte.
2. **Recoge los fragmentos de datos** que suelta el malware al morir. Te dan
   experiencia.
3. **Al subir de nivel**, el juego se pausa y eliges una de tres mejoras: más
   daño, más cadencia, más alcance, más velocidad, más integridad, que el
   malware se adapte más despacio (Actualizar firmas), menos espera entre
   cambios de personaje (Cambio en caliente) o recoger los fragmentos desde más
   lejos (Caché ampliada).
4. **El malware se adapta.** Cada 20 segundos se hace más resistente a la
   herramienta que más daño le ha hecho. Lo verás porque los números de daño y
   el anillo de tu herramienta se vuelven rojos. Actualizar firmas hace que se
   adapte más despacio.
5. **Cambia de personaje** para atacarle con otra herramienta. Hay tres:
   - **Espadachín · Firewall:** golpea todo lo que tienes alrededor.
   - **Mago · Ping:** dispara un paquete que salta de un enemigo a otro.
   - **Segador · Escáner:** un pulso lento y muy amplio.

   Después de cambiar hay que esperar 10 segundos para volver a hacerlo (menos
   con Cambio en caliente, hasta un mínimo de 4).
6. **Evoluciones.** Si eliges tres veces la misma mejora de daño, cadencia o
   alcance, aparece la evolución de una herramienta. Es mucho más fuerte y el
   malware todavía no ha aprendido a resistirla.
7. **La horda.** Casi todo el malware solo te persigue y hace daño al tocarte,
   pero hay dos que piden atención:
   - **Troyano** (caballo verde, desde el 4:00): cuando está cerca se para,
     parpadea en rojo y embiste en línea recta. Al verlo parpadear, apártate de
     lado.
   - **Ransomware** (candado rojo, desde el 6:00): muy lento, pero aguanta
     mucho y pega fuerte. Como mucho hay ocho a la vez; no dejes que te
     acorralen.
8. **Élites.** Cada minuto llega un Rootkit con uno o dos afijos, escritos
   sobre su cabeza:
   - **Blindado:** recibe la mitad de daño.
   - **Replicante:** al morir suelta más malware.
   - **Aura lenta:** si estás cerca, te frena.
   - **Explosivo:** al morir estalla. Aléjate del anillo naranja.
9. **El jefe final** llega a los 10 minutos. Cuando se pone rojo va a embestir
   en línea recta: apártate.

## Pantallas

- **Menú principal:** resumen de cómo se juega, tu mejor partida y los botones
  Jugar, Reglas, Opciones y Salir.
- **Reglas:** cuatro pestañas (cómo se juega, personajes, mejoras y enemigos)
  que explican qué hace cada cosa y qué personaje conviene en cada situación.
  Se cambia de pestaña con click o con las flechas.
- **Opciones:** volumen de la música y de los efectos, pantalla completa y
  filtro CRT. Se guardan solas.
- **Pausa:** continuar, opciones o volver al menú.
- **Resultados:** tiempo, nivel y malware eliminado. Avisa si has batido un
  récord.
