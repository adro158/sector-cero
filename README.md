<p align="center">
  <img alt="Icono de Sector Cero" width="128" src="projecte/medios/icono/icono.png">
</p>

# Sector Cero

**Eres un antivirus. Tu ordenador está infectado. Aguanta diez minutos.**

<p align="center">
  <a href="https://adro158.github.io/sector-cero/">
    <img alt="Jugar ahora en el navegador o en el móvil" src="https://img.shields.io/badge/%E2%96%B6%20JUGAR%20AHORA-en%20el%20navegador%20o%20el%20m%C3%B3vil-00d9f2?style=for-the-badge">
  </a>
  <br><br>
  <a href="https://adro158.github.io/sector-cero/">
    <img alt="Código QR para abrir el juego en el móvil" width="160" src="https://api.qrserver.com/v1/create-qr-code/?size=320x320&margin=12&data=https%3A%2F%2Fadro158.github.io%2Fsector-cero%2F">
  </a>
  <br>
  <sub>Escanea el QR con la cámara del móvil para jugar sin instalar nada.</sub>
</p>

Sector Cero es un videojuego en 2D hecho con Godot por Adam y Alan para la
asignatura "Demostra el teu talent". Es un *survivors-like*, como Vampire
Survivors: solo te mueves, tu herramienta ataca sola y cada vez llega más
malware. Lo que lo hace distinto: **el malware aprende**. Se vuelve resistente
a la herramienta que más daño le hace, así que tienes que cambiar de personaje
para sorprenderle.

![Una partida: el ransomware, los troyanos y la horda sobre la placa base](documentacio/capturas/juego/11_troyano_y_ransomware.png)

## Jugar

**En el móvil o sin descargar nada:** abre
[adro158.github.io/sector-cero](https://adro158.github.io/sector-cero/) (o
escanea el QR de arriba). En el móvil sale un joystick a la izquierda y los
botones de cambiar de personaje y de pausa a la derecha.

**En el ordenador, con el lanzador** (desde la v1.5):

1. Descarga de la última versión de
   [Releases](https://github.com/adro158/sector-cero/releases):
   - en Windows, `SectorCero_Instalador_vX.exe`, y ábrelo: Siguiente, elige
     la carpeta y Finalizar
   - en Linux, `SectorCero_Lanzador_linux_vX.zip`: descomprímelo y abre
     `SectorCero_Lanzador.x86_64`
2. En el lanzador, elige la versión en el desplegable (se descarga en un
   momento) y pulsa **JUGAR**. Al cerrar el juego vuelves al lanzador.

Desde el lanzador se juega a **todas** las versiones publicadas, de la
primera a la última. Las versiones nuevas aparecen solas, y el lanzador
también se actualiza solo: no hace falta volver a esta página.

Windows avisará de que el instalador no es de un editor conocido («Windows
protegió su PC»), porque no está firmado: pulsa **Más información** y
**Ejecutar de todas formas**.

Sigue estando el juego suelto, sin lanzador: el `.zip` de Windows o de Linux
de cada versión. Se descomprime y se abre `SectorCero.exe` (en Linux,
`SectorCero.x86_64`), y él mismo avisa de las versiones nuevas con
**ACTUALIZAR**.

| Acción | Teclado | Mando |
|---|---|---|
| Moverse | WASD o flechas | Stick izquierdo |
| Personaje siguiente / anterior | E o Tab / Q | Y / — |
| Ver el equipo | C | — |
| Lanzar la ulti (el Mago apunta con el ratón y lanza con click) | R | B |
| Pausa | Esc o P | Start |
| Elegir mejora | 1, 2, 3 o click | Cruceta y A |
| Ver la ficha de un enemigo | Click (click derecho la cierra) | — |
| Panel técnico | F3 | — |
| Menú de desarrollador | F1 | — |

## Cómo se juega

Aguanta 10 minutos contra oleadas de malware y derrota al jefe. Entonces el
sector queda dañado y empieza la fase 2; a los 15 minutos llega el jefe final,
NÚCLEO CERO, y derrotarlo es ganar. Los
enemigos sueltan fragmentos de datos; recógelos para subir de nivel y elegir
mejoras. Cada 20 segundos el malware se hace más resistente a la herramienta
que más le ha dañado: cuando veas tus números de daño en rojo, cambia de
personaje.

- **Tres personajes**, cada uno con su vida: el Espadachín (Firewall, golpea
  alrededor), el Mago (Ping, salta de un enemigo a otro) y el Segador (Escáner,
  un pulso amplio y lento). Si cae el que llevas, eliges quién sigue. Cada uno
  carga su ulti matando y la lanza con R.
- **Cinco tipos de malware**, entre ellos el troyano, que avisa en rojo y
  embiste, y el ransomware, un tanque durísimo.
- **Élites** cada minuto con habilidades al azar; si los matas, dejan un
  corazón que cura y un cofre con una ruleta de mejoras.
- **Evoluciones**: repite tres veces una mejora y tu herramienta evoluciona.
- **Dos jefes**: el de los 10 minutos, que embiste e invoca horda, y NÚCLEO
  CERO, con tres formas, los ataques de tus personajes, portales, hielo y un
  escudo que se rompe por sus anclas.
- **Ficha del enemigo**: haz click en cualquiera para ver su vida y su daño.
- **Tres dificultades**, que se eligen en el menú: en fácil el malware tiene
  menos vida, hace menos daño y huye cuando llega el jefe; en difícil, al
  revés.
- **Ranking** con las diez mejores partidas y la dificultad de cada una.

El manual completo está en el [manual de usuario](documentacio/manual_usuario.md).

| | |
|---|---|
| ![Menú principal](documentacio/capturas/juego/01_menu.png) | ![Subida de nivel](documentacio/capturas/juego/05_subida_de_nivel.png) |
| ![Élite con su ficha](documentacio/capturas/juego/07_elite_y_ficha.png) | ![El jefe de los 10 minutos](documentacio/capturas/juego/12_jefe.png) |
| ![La fase 2: el sector dañado](documentacio/capturas/juego/16_fase_2.png) | ![NÚCLEO CERO en su escudo, con sus cuatro anclas](documentacio/capturas/juego/18_escudo_y_anclas.png) |

## Cómo lo hicimos

Empezamos el 18 de septiembre con un repositorio vacío. El primer juego fue un
cuadrado amarillo perseguido por cuadrados rosas; dos semanas después hay tres
personajes, cinco enemigos, élites, un jefe, música propia y un ranking.

| Día | Lo que pasó |
|---|---|
| 18/09 | Repositorio, arquitectura y reparto del trabajo |
| 22/09 | Del 3D al 2D y de vampiros a un ordenador infectado; la primera horda |
| 24/09 | La arena de neón de Alan, los números de daño y el Ping |
| 29/09 | El malware que se adapta (nuestro elemento diferencial) y el simulador de partidas |
| 30/09 | Jefe final, sprites, toda la interfaz y el cambio de personaje |
| 01/10 | Mapa infinito, audio, élites, evoluciones, efectos y actualizaciones desde el juego |
| 02/10 | Arte nuevo, troyano y ransomware, y todo lo que cambiamos tras jugarlo |
| 06/10 | Aviso de versión nueva en plena partida, el juego en el móvil, una vida por personaje y el premio de los élites |
| 08 y 13/10 | Equilibrio tras jugarlo, un jefe más difícil, tres dificultades, las ultis y el menú de desarrollador |
| 14 y 15/10 | La horda animada, la explosión del rootkit y el menú de versiones |
| 16/10 | La fase 2 con el mapa destrozado, el jefe final NÚCLEO CERO y el icono del juego |

![Así empezó: cuadrados rosas persiguiendo a un cuadrado amarillo](documentacio/capturas/historia/02_primera_horda.png)
*Así era el juego el 22 de septiembre.*

La historia completa, con capturas reales de cada versión, está en
**[Historia del proyecto](documentacio/historia_del_proyecto.md)**.

## Documentación

- **[Historia del proyecto](documentacio/historia_del_proyecto.md)** — cómo
  evolucionó todo desde cero, con capturas. Empieza por aquí.
- [Documentación técnica](documentacio/documentacion_tecnica.md) — cómo está
  hecho por dentro.
- [Manual de usuario](documentacio/manual_usuario.md)
- [Créditos](documentacio/creditos.md) — de dónde sale cada gráfico y sonido.
- [Bitácora](documentacio/bitacora.md) — el diario de cada sesión, con todas
  las decisiones y pruebas.
- [Presentación](documentacio/presentacion.md) — guion de la defensa.
- [Flujo de trabajo](documentacio/flujo_de_trabajo.md) — Git, cómo ejecutar
  desde el código y cómo publicar una versión.

## Quiénes somos

- **Adam** — dirigió el proyecto: decidió qué hacer y cómo, pidió cada
  cambio, lo probó y lo revisó.
- **Alan** — hizo la primera arena con su fondo de neón, el primer HUD y el
  primer panel de mejoras, y probó el juego para decidir los últimos cambios.

**Uso de inteligencia artificial.** Las ideas y las decisiones son nuestras.
El código lo escribió sobre todo Claude (Anthropic) a partir de lo que le
pedíamos, y lo revisamos para poder explicarlo; la documentación también la
redactó Claude a partir de la bitácora de cada sesión. Los gráficos los hizo la IA
(Claude y Gemini) a partir de nuestras ideas, y el audio lo genera un script.
Está explicado en la [historia](documentacio/historia_del_proyecto.md#cómo-hemos-usado-la-inteligencia-artificial)
y en los [créditos](documentacio/creditos.md).

## Tecnologías

Godot 4.7.2 con GDScript y el renderizador Compatibility (OpenGL), shaders
propios, Git y GitHub (con una GitHub Action que publica cada versión) y Claude
como asistente de programación. Funciona en Windows y Linux.
