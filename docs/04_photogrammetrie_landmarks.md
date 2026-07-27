# Bâtiments emblématiques en haute fidélité (photogrammétrie ciblée)

*Procédure documentée à l'avance — rien à exécuter tant qu'il n'y a pas de photos.
Le pipeline COLMAP + OpenMVS est déjà installé et testé sur le VPS.*

## Principe

Le texturing procédural (voir `game/shaders/building_facade.gdshader`) habille les
1 498 bâtiments « en masse ». Les monuments qui font l'identité d'Alger méritent mieux :
on les remplacera **un par un** par des modèles photogrammétrés issus de vraies photos.

Cibles prioritaires (ordre suggéré) :

1. La Grande Poste (spawn actuel du joueur)
2. Façades du front de mer (bd Zighout Youcef / bd Che Guevara)
3. Le Milk Bar / immeubles de la place Émir Abdelkader
4. Théâtre national algérien (square Port-Saïd)

## Étape A — Acquisition des photos (à Alger, par toi ou un contact sur place)

- 100 à 300 photos par bâtiment, recouvrement 70-80 %, focale fixe, lumière diffuse
  (détails complets : [photogrammetry/README.md](../photogrammetry/README.md)).
- Smartphone récent suffisant ; **photos au sol uniquement** (drones réglementés en Algérie).
- Balayer chaque façade en arc, à plusieurs hauteurs si possible ; capturer les angles.

## Étape B — Traitement sur le VPS (une commande)

```bash
# 1. Envoyer les photos
scp -i ~/.ssh/odoc_vps_rsa -r ./photos_grande_poste root@151.80.144.236:/home/claude-agent/GTDZ/photogrammetry/input/grande_poste

# 2. Lancer le pipeline (la nuit : 6-14 h pour 100 photos, jusqu'à 24-48 h pour 300, sur 8 vCores)
ssh -i ~/.ssh/odoc_vps_rsa root@151.80.144.236 \
  "cd /home/claude-agent/GTDZ && nohup bash photogrammetry/scripts/run_photogrammetry.sh grande_poste > photogram.log 2>&1 &"
```

Sortie : `photogrammetry/output/grande_poste/mvs/scene_dense_mesh_texture.obj` (+ textures).

## Étape C — Nettoyage Blender (sur le PC)

1. Importer l'OBJ, supprimer le sol/les passants/le bruit autour du bâtiment.
2. `Decimate` (ratio ~0.1-0.3) pour passer de millions de triangles à ~50-100k.
3. Vérifier l'échelle par rapport à l'empreinte OSM (le bâtiment OSM fait foi) et
   aligner l'origine au niveau du sol.
4. Exporter en `.glb` vers `game/assets/landmarks/grande_poste.glb`.

## Étape D — Intégration Godot (automatisable par Claude)

1. Dans `osm/osm_to_mesh.py` : liste d'exclusion `LANDMARK_WAY_IDS` (ex. way 376558747
   pour la Grande Poste) pour ne plus générer la boîte grise correspondante.
2. Instancier le `.glb` haute fidélité à la position exacte (coordonnées calculées
   comme pour le spawn), avec collision trimesh (suffixe `-col` ou StaticBody généré).
3. LOD : `visibility_range_end` sur le modèle HD + boîte simplifiée au-delà de ~300 m.

## Coûts / alternatives

- 100 % gratuit avec le pipeline actuel (lent : nuits de calcul sur le VPS).
- Si un GPU NVIDIA devient disponible (futur PC fixe) : Meshroom local, 5-10x plus rapide.
- Alternative sans photos : modélisation manuelle Blender du landmark à partir
  d'images de référence trouvées en ligne (attention : s'inspirer, ne pas copier de
  modèles 3D non libres ni utiliser Google Maps/Street View comme source de textures).
