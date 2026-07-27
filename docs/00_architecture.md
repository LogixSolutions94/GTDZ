# GTDZ — Document d'architecture

*Version 1 — 27 juillet 2026. Rédigé après cadrage avec le chef de projet.*

## 1. Vision et périmètre

Un mini‑jeu PC (Windows en priorité, Linux possible) qui recrée **2 à 3 quartiers
emblématiques d'Alger** de façon réaliste, jouable en **vue 3e personne type GTA**,
destiné à évoluer vers un jeu de tir / arcade.

Décisions de cadrage validées :

| Question | Décision |
|---|---|
| Périmètre | 2‑3 quartiers emblématiques (pas toute la ville) |
| Quartier pilote | Front de mer / Alger‑Centre (Grande Poste, bd Zighout Youcef) |
| Extensions | La Casbah, Bab El Oued |
| Vue / gameplay | 3e personne type GTA, visée épaule pour le tir en phase 3 |
| VPS OVH | Impliqué dès maintenant (builds headless + photogrammétrie via Docker) |
| Machine de dev | PC Windows 11 |

## 2. Moteur de jeu : Godot 4.7

**Choix : Godot 4.7 avec GDScript.**

Justification par rapport au contexte (indie, open source, frugalité, VPS sans GPU) :

- **100 % open source (MIT)** : aucune royaltie, aucun compte éditeur, souveraineté
  totale sur le code et les builds — cohérent avec la philosophie du projet.
- **3D moderne suffisante pour l'objectif** : renderer Forward+ (SDFGI, SSAO, volumétrique),
  streaming de scènes, LOD, occlusion culling. Ce n'est pas Unreal, mais pour des quartiers
  photogrammétrés optimisés c'est largement au niveau.
- **Builds headless triviaux** : l'exécutable Godot tourne en `--headless` sur le VPS
  (image Docker `barichello/godot-ci`), ce qui permet des builds Linux/Windows automatisés
  sans GPU.
- **GDScript** : langage simple, très documenté, idéal quand le chef de projet relit le code
  sans être développeur au quotidien. C# reste possible plus tard sans tout réécrire.
- **Export web possible** plus tard (préférence exprimée, non prioritaire).

Alternatives écartées (réévaluables si le projet pivote) :

| Option | Pourquoi pas maintenant |
|---|---|
| Unreal Engine 5.5 | Pas open source, tooling très lourd, builds impossibles sur le VPS sans GPU. Reste l'option « AAA » documentée en §8. |
| Bevy (Rust) | Excellent moteur mais bas niveau : il faudrait écrire beaucoup de code moteur nous‑mêmes. |
| Three.js / Babylon.js | Une ville photogrammétrée entière dans le navigateur pose vite des problèmes de mémoire/perfs ; on garde l'idée pour un export web ultérieur. |
| Armory3D | Pipeline Blender→jeu séduisant mais communauté trop petite : risque projet. |

## 3. Pipeline d'assets 3D

Trois sources complémentaires, de la moins chère à la plus réaliste :

```
OpenStreetMap ──► extraction Overpass ──► extrusion Python ──► GLB basse fidélité
                                                                  │
Photos terrain ──► COLMAP (sparse) ──► OpenMVS (dense+mesh) ──► Blender (nettoyage, retopo, LOD)
                                                                  │
Modélisation manuelle Blender (landmarks : Grande Poste, etc.) ───┤
                                                                  ▼
                                                     game/assets/ (import Godot .glb)
```

1. **OSM d'abord** : le script [osm/extract_osm.py](../osm/extract_osm.py) télécharge
   bâtiments et rues d'un quartier via l'API Overpass ;
   [osm/osm_to_mesh.py](../osm/osm_to_mesh.py) extrude les empreintes de bâtiments en un
   mesh GLB. Résultat : un quartier « boîtes grises » à l'échelle réelle, jouable en
   quelques minutes. C'est la **colonne vertébrale** : gabarits, rues, proportions.
2. **Photogrammétrie ensuite** : photos au sol des façades et places →
   COLMAP (reconstruction sparse, CPU) → OpenMVS (densification, maillage, textures, CPU)
   → nettoyage/décimation dans Blender → remplacement progressif des boîtes grises.
   Pipeline scripté dans [photogrammetry/scripts/run_photogrammetry.sh](../photogrammetry/scripts/run_photogrammetry.sh).
3. **Modélisation manuelle** pour les landmarks où la photogrammétrie est insuffisante
   (Grande Poste, mosquées, monuments) : Blender, avec les photos comme référence.

Pourquoi COLMAP + OpenMVS plutôt que Meshroom : **le VPS OVH n'a pas de GPU**, or les
depth maps de Meshroom/AliceVision exigent CUDA. COLMAP (sparse) et OpenMVS tournent
entièrement sur CPU — plus lent, mais 12 vCores / 24 Go permettent de traiter des lots de
100 à 300 photos par nuit. Si un GPU NVIDIA est disponible sur le PC de dev, Meshroom
(GUI, très accessible) reste une option locale documentée dans le setup.

## 4. Données cartographiques et aspects légaux

- **OpenStreetMap (retenu)** : licence ODbL. Utilisation libre y compris commerciale, à
  deux conditions : afficher **« © les contributeurs d'OpenStreetMap »** dans le jeu
  (écran crédits), et republier sous ODbL toute *base de données dérivée* si on en
  distribue une (un jeu compilé est une « production », l'attribution suffit).
- **Google Maps / Earth (exclu)** : les CGU interdisent l'extraction de géométrie ou de
  textures pour un usage hors Google Maps. À ne jamais utiliser comme source d'assets.
- **Mapbox** : SDK propriétaire, données largement issues d'OSM ; aucun intérêt ici.
- **Photos de terrain** : attention au droit à l'image (flouter/éviter visages et plaques),
  et **l'usage de drones est strictement réglementé en Algérie** (autorisation préalable
  obligatoire) — le pipeline est donc conçu pour des **photos au sol**.

## 5. Rôle du VPS OVH (12 vCores / 24 Go)

Impliqué dès la phase 0, tout en Docker :

| Service | Image | Usage |
|---|---|---|
| Builds headless | `barichello/godot-ci:4.7.1` | Export Linux (et Windows plus tard) via [scripts/build/build_linux_headless.sh](../scripts/build/build_linux_headless.sh) |
| Photogrammétrie sparse | `colmap/colmap` | Étapes COLMAP du pipeline photos |
| Photogrammétrie dense | `gtdz/openmvs` (buildée localement, [Dockerfile](../scripts/vps/Dockerfile.openmvs)) | Densification, maillage, textures |
| Backend futur | — | Multijoueur, scores, leaderboards (phase 4+, non conçu ici) |

Installation : [scripts/install/install_vps.sh](../scripts/install/install_vps.sh) ;
orchestration : [scripts/vps/docker-compose.yml](../scripts/vps/docker-compose.yml).
Le transfert des photos vers le VPS et des meshes vers le PC se fait par `scp`/`rsync`
(documenté dans le setup).

## 6. Langages

| Langage | Usage |
|---|---|
| GDScript | Gameplay, scènes Godot |
| Python 3.12 | Outillage données (extraction OSM, génération de meshes) |
| Bash | Scripts VPS (install, builds, photogrammétrie) |
| PowerShell | Scripts Windows (install, build local) |

## 7. Arborescence

Voir le [README](../README.md). Principe : `game/` ne contient que ce que Godot importe ;
les **sources** lourdes (`.blend`, photos, sorties photogrammétrie) vivent hors du projet
Godot et sont exclues de git (Git LFS envisageable en phase 2).

## 8. Options payantes / propriétaires (pour plus tard)

Recommandation : **rester full open source pour la v1.** Options documentées si le projet grandit :

| Outil | Apport | Inconvénients |
|---|---|---|
| **Unreal Engine 5.5** | Rendu AAA (Nanite/Lumen), pipeline TPS/FPS clé en main, portage consoles | Propriétaire (5 % de royalties au‑delà de 1 M$), tooling lourd, exige un vrai GPU partout (dev **et** build), migration = réécriture quasi complète du gameplay |
| **RealityCapture** | Photogrammétrie bien plus rapide et précise que COLMAP ; gratuit depuis 2024 sous 1 M$ de CA | Propriétaire, Windows + GPU NVIDIA obligatoires (donc pas sur le VPS) |
| **Agisoft Metashape** | Photogrammétrie pro, tourne aussi sur CPU | ~180 € (Standard), propriétaire |
| **Packs d'assets (Fab, etc.)** | Props urbains, végétation, personnages | Licences par pack, style parfois incohérent avec la photogrammétrie |

Chemin de migration si besoin un jour : les assets (GLB/Blender) et les données OSM sont
portables tels quels vers Unreal ; seul le code GDScript serait à réécrire. C'est le moteur
qu'on changerait, pas le pipeline d'assets — raison de plus pour soigner ce dernier.
