# Lista de assets — Sector Cero

Documento de trabajo para Alan. Todo en PNG con transparencia salvo donde se
indique otra cosa.

## Estilo

Geométrico y de neón sobre fondo oscuro. El estilo lo sostienen sobre todo dos
piezas, no los sprites sueltos: una **tipografía monoespaciada** bien elegida y
un **shader de CRT/scanlines** a pantalla completa. Si esas dos están bien, los
enemigos pueden ser formas simples y el conjunto se lee como intencionado.

## Restricción técnica importante

Los enemigos de horda se dibujan con `MultiMeshInstance2D`: todas las instancias
de un mismo tipo comparten **una única textura y un único material**. Eso obliga
a un solo sprite por tipo, sin fotogramas de animación, y todos del mismo tamaño.
El movimiento visual lo pone un shader de glitch, no una animación dibujada.

Los élites y el jefe sí son nodos normales y pueden llevar animación.

---

## MVP imprescindible

### Enemigos de horda

Tres tipos en el MVP. Cubren los tres comportamientos básicos del género
(numeroso, rápido y resistente), que es suficiente para que las oleadas se noten
distintas entre sí.

| Sprite | Tamaño | Rol |
|---|---|---|
| Bit corrupto | 24×24 | Básico, lento, muy numeroso |
| Paquete perdido | 24×24 | Rápido y frágil |
| Proceso colgado | 40×40 | Lento y resistente |

### Élites y jefe

| Asset | Tamaño | Notas |
|---|---|---|
| Rootkit (élite) | 64×64 | 2-3 fotogramas opcionales |
| Troyano (élite) | 64×64 | 2-3 fotogramas opcionales |
| Kernel Panic (jefe) | 128×128 | Sprite base + 2-3 fotogramas de aviso de ataque |

Los afijos de los élites (blindado, replicante, aura ralentizadora, explota al
morir) **no necesitan sprites propios**: se comunican con tinte de color y
contorno por shader sobre el mismo sprite.

### Jugador

| Asset | Tamaño | Notas |
|---|---|---|
| Proceso antivirus | 32×32 | Un solo sprite, sin variantes por dirección |

### Armas y proyectiles

Dos armas en el MVP, elegidas por contraste: una de corto alcance que premia
meterse entre los enemigos, y una a distancia. Las evoluciones son el mismo
sprite recoloreado y escalado, no dibujos nuevos.

| Arma | Sprite | Comportamiento |
|---|---|---|
| Firewall | Anillo 96×96 | Aura permanente alrededor del jugador |
| Ping | Punto 12×12 | Proyectil que rebota |

### Recogibles

| Asset | Tamaño | Notas |
|---|---|---|
| Fragmento de datos | 12×12 | Un sprite y tres tintes según valor |
| Imán | 24×24 | Atrae todas las gemas |
| Parche de reparación | 24×24 | Cura |

### Escenario

| Asset | Notas |
|---|---|
| Suelo de placa base | Textura 256×256 que tile sin costura |
| Borde de la arena | Franja que marque el límite del mapa |

### Partículas

| Asset | Uso |
|---|---|
| Cuadrado sólido 8×8 | Muerte de enemigo, impactos |
| Chispa 16×16 | Recogida de gema, subida de nivel |

### Interfaz

| Asset | Notas |
|---|---|
| Barra de vida y barra de XP | Marco + relleno |
| Marco de tarjeta de mejora | 1 marco + 3 colores de rareza |
| Iconos de mejora pasiva | 5-6 de 32×32 (velocidad, daño, área, imán, vida) |
| Iconos de arma | Reutilizar el sprite del arma correspondiente |
| Título del juego | Logo para el menú principal |
| Botones | Un estilo, tres estados: normal, encima, pulsado |

### Tipografía y shaders

| Asset | Notas |
|---|---|
| Fuente monoespaciada | No hay que dibujarla, hay que elegirla bien |
| Shader CRT/scanlines | Post-proceso a pantalla completa. Máximo impacto por menos horas |
| Shader de glitch | Para los enemigos de horda, sustituye a la animación |
| Shader de destello al golpear | Blanco momentáneo al recibir daño |

### Audio

| Asset | Cantidad |
|---|---|
| Música de partida | 1 loop |
| Música de menú | 1 loop |
| Efectos | ~10: disparo ×3, impacto, muerte de enemigo, recoger gema, subir nivel, daño al jugador, clic de interfaz, fin de partida |

---

## Opcional, solo si sobra tiempo

Por orden de prioridad si hay margen:

1. **Dos armas más**: Escáner (haz 128×16, barrido giratorio) y Cuarentena
   (zona 80×80 que se deja en el suelo). Son las que más falta hacen, porque el
   elemento diferencial del proyecto depende de que diversificar armas sea una
   decisión real
2. Dos tipos de enemigo de horda más: Gusano (32×32, se divide al morir) y
   Popup (20×20, enjambre muy rápido)
3. Quinta arma: Purga (destello 48×48, golpea a un enemigo cercano al azar)
4. Decoración del suelo: chips, condensadores, pistas sueltas (3-4 sprites)
5. Un segundo jefe intermedio
6. Iconografía para la pantalla de resultados
7. Variantes de color del escenario según el minuto de partida

---

## Orden de recorte

Si aun así no se llega, se recorta en este orden:

1. La segunda música
2. Los fotogramas de animación de los élites
3. El borde decorado de la arena

Lo último que se toca son **la tipografía y el shader de CRT**, porque son los
que sostienen que el juego parezca una pieza coherente y no un conjunto de
piezas sueltas.
