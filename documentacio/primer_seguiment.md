<!--
Plantilla del informe del primer seguimiento, tal como la dio el profesor (en
catalán). Solo se han quitado unos números de nota al pie que se colaron en el
texto al exportarla. NO editar el contenido de la plantilla.
-->

# Estructura del primer seguiment

**Fecha de entrega: 2 de octubre de 2026.**

## 1. Resum de l'Estat i Avenç

- **Percentatge d'Avenç:** Estat actual del projecte respecte a les 60 hores
  suggerides i a les 6 Fites.
- **Fites Cobertes:** Confirmació de la realització de la Fita 1 (Planificació i
  Muntatge) i la Fita 2 (Mecànica Principal).
- **Objectiu de l'Entrega:** Breu descripció del que ja és jugable o interactiu i
  la demostració d'aquesta funcionalitat.

## 2. Implementació de l'MVP i Funcionalitat Central

- **Mecànica Principal:** Estat de la implementació de la mecànica principal.
  - Confirmació que la mecànica és **funcional**.
- **Estructures d'Escenes:** Detall sobre les dues escenes diferents previstes i
  si ja estan creades o estan en desenvolupament.
- **Controls i Interacció:** Confirmació que els controls bàsics (teclat+ratolí o
  tàctil) estan operatius per a la mecànica.

## 3. Qualitat Tècnica i Estructures Bàsiques

- **Qualitat del Codi:** Avaluació de l'adherència als requisits de **codi net i
  organitzat** i **C# modular**.
- **Control de Versions:** Estat i salut del repositori Git.
- **Arbori d'Assets:** Estructura bàsica de les carpetes d'assets i confirmació de
  l'ús d'assets lliures o propis amb els crèdits corresponents.

## 4. Pròxims Passos i Gestió de Riscos

- **Focus Immediat:** Planificació i objectius per a la **Fita 3 (UI i UX)** i la
  **Fita 4 (Persistència i Àudio/Animacions)**.
  - Revisió de l'**abast** per assegurar la cobertura de l'MVP abans de les 60
    hores.
- **Incidències i Desviacions:** Documentació de qualsevol desviació del temps o de
  l'abast i proposta de plans de mitigació.
- **Testatge:** Mètodes de *test* emprats i resultats bàsics del testatge de la
  funcionalitat implementada.

---

# Notas para rellenarlo (en castellano, no forman parte de la plantilla)

- **De dónde sacar los datos:** el estado real está en `bitacora.md` (horas,
  decisiones, problemas, métodos de test) y en `requisitos_y_estado.md` (qué
  requisito está hecho y cuál falta). El reparto de fitas, en `planificacion.md`.
- **La plantilla es genérica y no encaja del todo con nuestro proyecto:**
  - Habla de "C# modular": nosotros usamos **GDScript** en Godot 4.7.2. Adaptar
    esa frase.
  - Habla de "teclado+ratón o táctil": nuestros controles son **teclado
    (WASD/flechas) y mando**, más ratón en los menús.
  - Habla de la Fita 1 y la 2 como cubiertas: en realidad ya hay trabajo hecho de
    las fitas 3 y 4 (interfaz completa, jefe, elemento diferencial). Se puede
    decir que vamos por delante de lo previsto en jugabilidad y por detrás en
    persistencia y audio.
- **Porcentaje de avance:** se calcula con las horas acumuladas de la bitácora
  sobre las 60 sugeridas.
- **Honestidad con los riesgos:** persistencia y audio siguen sin implementar y
  el rendimiento no está validado en una máquina con GPU real. Eso va en el
  apartado 4, con su plan de mitigación.
