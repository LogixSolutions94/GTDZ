# Crédits et licences des ressources

## Données cartographiques

- **OpenStreetMap** — géométrie des bâtiments et des rues d'Alger.
  © les contributeurs d'OpenStreetMap, licence [ODbL](https://opendatacommons.org/licenses/odbl/).
  Mention affichée en permanence dans le jeu (HUD).

## Armes 3D (`game/assets/weapons/quaternius/`)

- **Quaternius — Ultimate Guns Pack** : AK-47 et SMG low-poly.
  Licence [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/)
  (preuves : pages Poly Pizza et quaternius.com, License.txt dans le dossier).

## Personnages 3D

- **Quaternius — Ultimate Animated Character Pack** (`game/assets/characters/quaternius/`)
  Licence [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) (domaine public,
  usage commercial autorisé). Source : https://quaternius.com — copie de la licence dans
  le dossier (`License.txt`). Merci Quaternius !

## Textures (`game/assets/textures/`)

- **ambientCG** — licence [CC0 1.0](https://docs.ambientcg.com/license/) (domaine public,
  usage commercial autorisé). Source : https://ambientcg.com — assets utilisés :
  PaintedPlaster017/004/005/006 (façades), Plaster001/003 (crépis), Concrete016
  (toits plats), RoofingTiles013A (tuiles), Asphalt031 (routes), PavingStones136
  (trottoirs). Merci ambientCG !
- Les **fenêtres** des façades sont générées procéduralement par
  `game/shaders/building_facade.gdshader` (aucune banque CC0 ne propose de façades
  résidentielles avec fenêtres — vérifié sur ambientCG et Poly Haven le 27/07/2026).

## Monuments — photos Wikimedia Commons

- **Théâtre national algérien** (`game/assets/textures/landmarks/tna.jpg`) —
  texture dérivée (recadrage) de « Théâtre National Algérien.jpg » par
  **Bernard Gagnon**, licence [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/),
  source : https://commons.wikimedia.org/wiki/File:Théâtre_National_Algérien.jpg
- **Grande Poste d'Alger** (`game/assets/textures/landmarks/grande_poste.jpg`) —
  texture dérivée (recadrage/redimensionnement) de « The Great Post Office.jpg »
  par **Idir Amokrane**, licence [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/),
  source : https://commons.wikimedia.org/wiki/File:The_Great_Post_Office.jpg —
  **la texture dérivée reste sous CC BY-SA 4.0.**
- Cinq autres photos libres de la Grande Poste (auteurs : Hacen Youcef Moudjahed,
  Ludovic Courtès, Xiaotong Gao, habib kaki, Chettouh Nabil — licences CC BY 3.0 à
  CC BY-SA 4.0) sont inventoriées pour usage futur ; détails et attributions dans
  [docs/04_photogrammetrie_landmarks.md](docs/04_photogrammetrie_landmarks.md).

## Ciel

- **Poly Haven** — HDRI « Kloofendal 48d Partly Cloudy (Pure Sky) »
  (`game/assets/textures/sky/`), licence [CC0](https://polyhaven.com/license).
  https://polyhaven.com — merci Poly Haven !
- Les cartes de relief (`*_n.jpg`) proviennent des mêmes assets ambientCG CC0
  que les textures couleur.

## Props urbains 3D (`game/assets/props/`)

- **Kenney** — City Kit Commercial, City Kit Roads, Retro Urban Kit, Survival Kit :
  lampadaires, feux, bancs, bennes, barrières, cônes, auvents, caisses/étals.
  Licence **CC0** (License.txt de chaque pack conservé dans le dossier).
  https://kenney.nl — merci Kenney !

## Code adapté de projets open source

- **bukkbeek — GodotFPS-Template** (MIT) : la logique du véhicule conduisible
  (`game/scripts/systems/vehicle.gd` — conduite VehicleBody3D, entrée/sortie,
  caméra embarquée) est adaptée de son `vehicle.gd`.
  https://github.com/bukkbeek/GodotFPS-Template — merci bukkbeek !
  (Ses sons proviennent de Pixabay et ne sont pas repris.)

## Inspirations code (non copié, patterns réimplémentés)

- **GDQuest — godot-4-3d-third-person-controller** (code MIT) : structure caméra
  orbitale / SpringArm / rotation du skin. Leurs assets 3D (CC-BY-NC-SA) ne sont
  **pas** utilisés dans ce projet.
- **Kenney — Starter Kit FPS** (MIT, assets CC0) : référence pour la structure
  arme/munitions. Les **sons** (`game/assets/sounds/kenney/` : blaster, enemy_attack,
  enemy_hurt, enemy_destroy, jump_a, land) proviennent de ce kit — **CC0** —
  https://github.com/KenneyNL/Starter-Kit-FPS / https://kenney.nl — merci Kenney !
- **chafmere — Godot4-FPS-Template** (MIT) : architecture WeaponResource à adopter
  quand on passera au multi-armes.

## Moteur

- **Godot Engine** (MIT) — https://godotengine.org
