# Crédits et licences des ressources

## Données cartographiques

- **OpenStreetMap** — géométrie des bâtiments et des rues d'Alger.
  © les contributeurs d'OpenStreetMap, licence [ODbL](https://opendatacommons.org/licenses/odbl/).
  Mention affichée en permanence dans le jeu (HUD).

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

- **Grande Poste d'Alger** (`game/assets/textures/landmarks/grande_poste.jpg`) —
  texture dérivée (recadrage/redimensionnement) de « The Great Post Office.jpg »
  par **Idir Amokrane**, licence [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/),
  source : https://commons.wikimedia.org/wiki/File:The_Great_Post_Office.jpg —
  **la texture dérivée reste sous CC BY-SA 4.0.**
- Cinq autres photos libres de la Grande Poste (auteurs : Hacen Youcef Moudjahed,
  Ludovic Courtès, Xiaotong Gao, habib kaki, Chettouh Nabil — licences CC BY 3.0 à
  CC BY-SA 4.0) sont inventoriées pour usage futur ; détails et attributions dans
  [docs/04_photogrammetrie_landmarks.md](docs/04_photogrammetrie_landmarks.md).

## Inspirations code (non copié, patterns réimplémentés)

- **GDQuest — godot-4-3d-third-person-controller** (code MIT) : structure caméra
  orbitale / SpringArm / rotation du skin. Leurs assets 3D (CC-BY-NC-SA) ne sont
  **pas** utilisés dans ce projet.

## Moteur

- **Godot Engine** (MIT) — https://godotengine.org
