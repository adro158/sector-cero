# Vampire Survivors 3D

Projecte acadèmic per a l'assignatura "Demostra el teu talent": una experiència
interactiva que demostra les nostres capacitats com a desenvolupadors de
videojocs.

## Descripció

Un "survivors-like" en 3D amb càmera cenital en perspectiva 3/4. El jugador
només controla el moviment; les armes ataquen soles. Onades d'enemics que
persegueixen el jugador, deixen anar gemmes d'experiència, pugen de nivell i
trien millores. Partida cronometrada de 10-15 minuts amb un boss final.

## Equip

- **Adam** — nucli de gameplay (moviment, càmera, enemics, armes, dany,
  experiència i nivells, director d'onades)
- **Alan** — UI/menús, persistència, àudio, escena de l'arena i il·luminació,
  assets, partícules, shaders, documentació i testeig

## Estructura del repositori

- `projecte/` — projecte de Godot 4.7.2
- `documentacio/` — memòria i documentació lliurable

## Motor

Godot 4.7.2 (GDScript). Plataforma objectiu: PC (Windows/Linux).
Renderitzador: **Compatibility** (OpenGL), no Forward+.

## Flux de treball

### Missatges de commit

```
<tipus>(<àmbit>): <descripció en imperatiu i minúscula>
```

Tipus: `feat` (funcionalitat nova), `fix` (correcció d'un error),
`refactor` (canvi intern sense canviar comportament), `chore` (configuració,
estructura), `docs` (documentació), `assets` (models, textures, so).

Àmbits: `player`, `enemies`, `weapons`, `progression`, `waves`, `ui`, `audio`,
`save`, `arena`, `godot`.

Exemples:

```
feat(player): add camera-relative movement with acceleration
fix(enemies): correct separation force at high densities
chore(godot): register autoloads and input map
assets(arena): add floor and wall textures
```

Un commit = una unitat de treball amb sentit propi. Ni un commit per fitxer,
ni un commit setmanal amb tot barrejat.

### Branques

- `main` sempre ha de poder executar-se. No es treballa directament sobre ella.
- Cada funcionalitat va a la seva branca: `feature/<àmbit>-<descripció-curta>`,
  per exemple `feature/player-movement` o `feature/ui-hud`.
- Cadascú treballa només a les seves branques.
- Abans de fusionar: `git pull` de `main` cap a la teva branca, resoldre els
  conflictes **allà**, i després fusionar cap a `main` amb `--no-ff` perquè
  l'historial mostri l'agrupació de la funcionalitat.
- Fusionar cap a `main` cada dia o dos, mai un cop per setmana.

### Regla d'or amb les escenes

Els fitxers `.tscn` es fusionen malament a Git. Mai editem la mateixa escena
alhora. L'arquitectura ja ho evita: cadascú té les seves escenes i la
comunicació passa pel `EventBus` i pels noms de grup, no per referències
directes entre nodes.
