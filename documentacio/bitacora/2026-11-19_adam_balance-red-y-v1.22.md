# 19/11/2026 — Adam — El resto del balance, la red sin tirones y la v1.22 para Alan

**Participantes:** Adam (con Claude Code). **Duración:** 2 h (con lo del 18/11,
que no era día de proyecto: «se apuntará todo lo que he hecho hoy y lo que voy
a hacer mañana en la misma»). **Horas acumuladas:** 57 h. Escrita el 24/11:
esa sesión no se cerró con `/cerrar`.

## Qué se ha hecho

1. **Los PR de skins de Alan** (#21, #22 y #28), revisados con una copia
   junto al #29: se juntan sin conflictos, importan sin errores y la prueba
   en red sale igual. Aprobados con la cuenta de Adam; los fusionó Alan.
2. **El resto del balance de la #27:**
   - la embestida de Kernel Panic, más rápida y larga contra un jugador
     rápido (hasta 1,5)
   - las anclas de NÚCLEO CERO, de 300 a 450 de vida
3. **El PR #31** (`contexto.md`: la votación, la ulti y la jaula) y la #19
   cerrada.
4. **El PR #32:** los élites y los jefes sin tirones en red
   (`movimiento_red.gd`: van hacia el sitio del estado a la velocidad justa).
5. **Las misiones, los bits y el pase**, decididos y apuntados para Alan en
   un comentario de la #16, con el prompt del asset de la moneda.
6. **Alan también publica** (#33). Con el sí de Adam, fusionados #33, #29,
   #32 y #31, y las novedades de la v1.22 escritas. Alan publicó la v1.22 el
   23/11.

## Métodos de test

- Simulador desde el minuto 15: el escudo pasa de unos 19 s a entre 16 y
  36 s, y se sigue ganando. Desde el minuto 10, el mismo resultado.
- Dos copias en red con un élite: en el cliente se mueve en 81 de cada 120
  pasos, sin saltos.
