# GTDZ — Alger City Game

Mini‑jeu PC open source qui recrée des quartiers emblématiques d'Alger en 3D réaliste
(vue 3e personne type GTA), avec pour objectif d'évoluer vers un jeu de tir / arcade.

## Périmètre v1

- **Quartier pilote** : Front de mer / Alger‑Centre (Grande Poste, bd Zighout Youcef).
- **Extensions prévues** : La Casbah, Bab El Oued.
- **Vue** : 3e personne (caméra épaule type GTA), visée épaule prévue en phase 3.

## Stack

| Rôle | Outil | Licence |
|---|---|---|
| Moteur de jeu | Godot 4.7 (GDScript) | MIT |
| Modélisation / nettoyage 3D | Blender | GPL |
| Photogrammétrie (CPU, sur VPS) | COLMAP + OpenMVS | BSD / AGPL |
| Géométrie de la ville | OpenStreetMap (API Overpass) | ODbL |
| Builds headless & photogrammétrie | Docker sur VPS OVH | — |

Détails et justifications : [docs/00_architecture.md](docs/00_architecture.md)

## Démarrage rapide

1. **Windows (machine de dev)** : exécuter `scripts/install/install_windows.ps1` (voir [docs/01_setup.md](docs/01_setup.md)).
2. Ouvrir `game/project.godot` dans Godot 4.7 et lancer la scène (`F5`) : une zone de test avec un personnage jouable (ZQSD/WASD + souris).
3. **VPS OVH (Ubuntu/Debian)** : cloner le repo puis exécuter `scripts/install/install_vps.sh`.

## Arborescence

```
GTDZ/
├── game/                  # Projet Godot 4.7 (scènes, scripts GDScript)
├── assets/                # Sources d'assets (fichiers .blend, textures, photos de référence)
├── osm/                   # Extraction OpenStreetMap + génération de ville basse fidélité
├── photogrammetry/        # Pipeline photos → mesh 3D (COLMAP + OpenMVS)
│   ├── input/<dataset>/   #   photos brutes par quartier
│   └── output/<dataset>/  #   résultats (nuages de points, meshes texturés)
├── scripts/
│   ├── install/           # Scripts d'installation (Windows + VPS Linux)
│   ├── build/             # Builds headless (Windows + Linux/Docker)
│   └── vps/               # Dockerfiles + docker-compose pour le VPS
├── builds/                # Sorties de build (ignorées par git)
└── docs/                  # Architecture, setup, roadmap
```

## Documentation

- [00_architecture.md](docs/00_architecture.md) — choix techniques, pipeline d'assets, rôle du VPS, aspects légaux, options payantes.
- [01_setup.md](docs/01_setup.md) — installation pas à pas (Windows + VPS) et premier build.
- [02_roadmap.md](docs/02_roadmap.md) — plan de travail par phases (0 → 3).

## Licences des données

La géométrie urbaine provient d'OpenStreetMap : toute distribution du jeu doit inclure
la mention **« © les contributeurs d'OpenStreetMap, ODbL »**. Voir la section légale de
[00_architecture.md](docs/00_architecture.md).
