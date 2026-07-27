#!/usr/bin/env bash
# GTDZ - Installation côté VPS OVH (Ubuntu 22.04+ / Debian 12+).
# Installe Docker si absent, télécharge les images de build et de photogrammétrie,
# compile l'image OpenMVS. À lancer depuis la racine du repo cloné :
#     bash scripts/install/install_vps.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GODOT_VERSION="${GODOT_VERSION:-4.7.1}"

echo ">> Mise à jour des paquets..."
sudo apt-get update -y
sudo apt-get install -y curl git rsync

if ! command -v docker >/dev/null 2>&1; then
    echo ">> Installation de Docker (script officiel get.docker.com)..."
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker "$USER"
    echo "   NOTE : déconnecte/reconnecte ta session SSH pour utiliser docker sans sudo."
else
    echo ">> Docker déjà installé."
fi

echo ">> Image Godot CI ${GODOT_VERSION} (builds headless, templates inclus)..."
sudo docker pull "barichello/godot-ci:${GODOT_VERSION}"

echo ">> Image COLMAP (photogrammétrie sparse, CPU)..."
sudo docker pull colmap/colmap:latest

echo ">> Build de l'image OpenMVS (compilation : 20 à 40 min sur ce VPS, une seule fois)..."
sudo docker build -t gtdz/openmvs -f "$REPO_DIR/scripts/vps/Dockerfile.openmvs" "$REPO_DIR/scripts/vps"

echo ""
echo "Installation VPS terminée."
echo "  - Build du jeu   : bash scripts/build/build_linux_headless.sh"
echo "  - Photogrammétrie : bash photogrammetry/scripts/run_photogrammetry.sh <dataset>"
