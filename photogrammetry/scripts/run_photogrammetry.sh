#!/usr/bin/env bash
# GTDZ - Pipeline photogrammétrie 100 % CPU (adapté au VPS OVH sans GPU) :
#   COLMAP (features -> matching -> reconstruction sparse -> undistort)
#   puis OpenMVS (densification -> maillage -> texturing).
#
# Usage :
#   bash photogrammetry/scripts/run_photogrammetry.sh <dataset> [exhaustive|sequential]
#     <dataset>   : nom du dossier de photos dans photogrammetry/input/
#     matcher     : exhaustive (défaut, < ~500 photos) ou sequential (photos prises en marchant)
#
# Durée indicative sur 12 vCores : plusieurs heures pour 100-300 photos.
set -euo pipefail

DATASET="${1:?Usage: run_photogrammetry.sh <dataset> [exhaustive|sequential]}"
MATCHER="${2:-exhaustive}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"   # dossier photogrammetry/
IN_HOST="$ROOT/input/$DATASET"
OUT_HOST="$ROOT/output/$DATASET"
[ -d "$IN_HOST" ] || { echo "Erreur : aucune photo dans $IN_HOST" >&2; exit 1; }
mkdir -p "$OUT_HOST/colmap" "$OUT_HOST/mvs"

# Chemins vus depuis les conteneurs (photogrammetry/ monté sur /data).
IN="/data/input/$DATASET"
OUT="/data/output/$DATASET"

colmap() {
    docker run --rm -v "$ROOT":/data colmap/colmap:latest colmap "$@"
}
openmvs() {
    local tool="$1"; shift
    docker run --rm -v "$ROOT":/data -w "$OUT/mvs" gtdz/openmvs "$tool" "$@"
}

echo ">> [1/8] Extraction des features (SIFT, CPU)..."
colmap feature_extractor \
    --database_path "$OUT/colmap/database.db" \
    --image_path "$IN" \
    --SiftExtraction.use_gpu 0

echo ">> [2/8] Matching ($MATCHER, CPU)..."
colmap "${MATCHER}_matcher" \
    --database_path "$OUT/colmap/database.db" \
    --SiftMatching.use_gpu 0

echo ">> [3/8] Reconstruction sparse (mapper)..."
mkdir -p "$OUT_HOST/colmap/sparse"
colmap mapper \
    --database_path "$OUT/colmap/database.db" \
    --image_path "$IN" \
    --output_path "$OUT/colmap/sparse"

echo ">> [4/8] Undistortion des images..."
colmap image_undistorter \
    --image_path "$IN" \
    --input_path "$OUT/colmap/sparse/0" \
    --output_path "$OUT/colmap/dense" \
    --output_type COLMAP

echo ">> [5/8] Conversion vers OpenMVS..."
openmvs InterfaceCOLMAP -i "$OUT/colmap/dense" -o scene.mvs

echo ">> [6/8] Densification du nuage de points (long)..."
openmvs DensifyPointCloud scene.mvs

echo ">> [7/8] Reconstruction du maillage..."
openmvs ReconstructMesh scene_dense.mvs

echo ">> [8/8] Texturing + export OBJ..."
openmvs TextureMesh scene_dense_mesh.mvs --export-type obj

echo ""
echo "Terminé. Résultats dans photogrammetry/output/$DATASET/mvs/"
echo "  - scene_dense_mesh_texture.obj (+ .mtl et textures) : à ouvrir dans Blender"
echo "Étapes suivantes : nettoyage/décimation Blender, export .glb vers game/assets/."
