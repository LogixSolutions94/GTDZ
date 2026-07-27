# Ressources open source réutilisables

*Recherche effectuée le 27 juillet 2026 — tous les dépôts vérifiés (licence, activité, compatibilité Godot 4).*

## Top 3 à intégrer en premier

1. **[gdquest-demos/godot-4-3d-third-person-controller](https://github.com/gdquest-demos/godot-4-3d-third-person-controller)**
   — contrôleur TPS conçu pour être transplanté dans un autre projet, maintenu (2026),
   Godot 4 natif. Remplacera notre capsule de la phase 0 (animations, caméra, feeling).
   Licence mixte : code libre GDQuest, assets avec attribution — à vérifier avant usage des assets.
2. **[vvoovv/blosm](https://github.com/vvoovv/blosm)** (ex blender-osm) — import OSM dans
   Blender en quelques clics (bâtiments avec hauteurs, routes avec largeur, terrain).
   Complète/remplace notre script d'extrusion maison pour la géométrie de masse. GPL
   (l'addon), mais les meshes exportés nous appartiennent. Version premium payante optionnelle.
3. **[TheDuckCow/godot-road-generator](https://github.com/TheDuckCow/godot-road-generator)**
   — routes, carrefours et trafic « lane-following » en pur GDScript, MIT, très actif.
   La brique la plus coûteuse à écrire soi-même pour un GTA-like ; à intégrer en phase 2/3.

## Contrôleurs / démos TPS Godot 4

| Repo | Licence | État | Intérêt |
|---|---|---|---|
| [godotengine/tps-demo](https://github.com/godotengine/tps-demo) | MIT (code), CC-BY 3.0 (assets) | Maintenu (officiel) | TPS complet : visée, animations, IA ennemis — étalon qualité |
| [gdquest-demos/godot-4-3d-third-person-controller](https://github.com/gdquest-demos/godot-4-3d-third-person-controller) | Mixte (voir LICENSE) | Maintenu | Contrôleur transplantable, point de départ le plus rapide |
| [Jeh3no/Godot-Third-Person-Controller](https://github.com/Jeh3no/Godot-Third-Person-Controller) | MIT | Maintenu | 100 % MIT, simple, sans contrainte d'attribution |
| [godotengine/godot-demo-projects](https://github.com/godotengine/godot-demo-projects) | MIT | Maintenu (officiel) | Mine de démos : navigation, véhicules, etc. |

## Jeux open world / GTA-like (lecture de code, inspiration)

| Repo | Licence | État | Intérêt |
|---|---|---|---|
| [rwengine/openrw](https://github.com/rwengine/openrw) | GPL v3 | Semi-sommeil | Architecture d'un vrai GTA (streaming, spawn piétons/trafic). **GPL : ne pas copier le code**, seulement s'inspirer |
| [carla-simulator/carla](https://github.com/carla-simulator/carla) | MIT | Très actif | Traffic Manager + piétons : la meilleure référence pour l'IA de circulation |
| [depixeled-chris/gta7](https://github.com/depixeled-chris/gta7) | MIT | Actif | Slice GTA minimaliste (Three.js) très lisible : trafic, piétons, police |

À éviter : re3/reVC (décompilations GTA, retirées par DMCA — risque juridique).

## Import OSM → Blender / Godot

| Repo | Licence | État | Intérêt |
|---|---|---|---|
| [vvoovv/blosm](https://github.com/vvoovv/blosm) | GPL (addon) | Maintenu | OSM → Blender (bâtiments, routes, terrain) → export glTF vers Godot |
| [tordanik/OSM2World](https://github.com/tordanik/OSM2World) | MIT | Maintenu | OSM → glTF en ligne de commande, 250+ tags gérés — automatisable sur le VPS |
| [RodZill4/godot-openstreetmap](https://github.com/RodZill4/godot-openstreetmap) | MIT | Peu actif | OSM → Godot direct en GDScript avec tuiles autour du joueur |

## Streaming, terrain, navigation, véhicules (phase 2+)

| Repo | Licence | État | Intérêt |
|---|---|---|---|
| [TokisanGames/Terrain3D](https://github.com/TokisanGames/Terrain3D) | MIT | Très actif | Terrain clipmap 65 km, 10 LOD — la baie et les hauteurs d'Alger |
| [navigation_mesh_chunks (démo officielle)](https://github.com/godotengine/godot-demo-projects/tree/master/3d/navigation_mesh_chunks) | MIT | Maintenu | Navmesh baké par chunks — indispensable pour les piétons en ville streamée |
| [SlashScreen/chunx](https://github.com/SlashScreen/chunx) | MIT | Peu maintenu | Streaming de scène par chunks — petite base à forker |
| [Dente222/MAdvanced-Vehicle-Controller](https://github.com/Dente222/MAdvanced-Vehicle-Controller) | MIT | Actif | Physique véhicule + IA de suivi de chemin |
| [smix8/Godot_3D_Navigation_Jump_Links](https://github.com/smix8/Godot_3D_Navigation_Jump_Links) | MIT | Archivé | Liens de saut navmesh (escaliers de la Casbah) — copiable tel quel |

Note LOD : Godot 4 intègre nativement le mesh LOD automatique et les visibility ranges
(HLOD) — pas d'addon nécessaire.

## Règle de licence pour le projet

Avant d'importer du code externe : MIT/Apache → OK partout ; GPL → OK pour des **outils**
(addons Blender, scripts de pipeline) mais **pas de copie dans le code du jeu** tant que la
licence du jeu n'est pas décidée ; assets CC-BY → crédits obligatoires dans le jeu.
