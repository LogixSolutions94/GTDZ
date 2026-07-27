#!/usr/bin/env bash
# GTDZ - Build headless Linux via Docker (image barichello/godot-ci, templates inclus).
# Usage (sur le VPS ou toute machine avec Docker) :
#     bash scripts/build/build_linux_headless.sh
set -euo pipefail

GODOT_VERSION="${GODOT_VERSION:-4.7.1}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

mkdir -p "$REPO_DIR/builds/linux"

echo ">> Export Linux (Godot ${GODOT_VERSION} headless)..."
docker run --rm \
    -v "$REPO_DIR":/repo \
    -w /repo/game \
    "barichello/godot-ci:${GODOT_VERSION}" \
    godot --headless --export-release "Linux" /repo/builds/linux/GTDZ.x86_64

echo "Build OK : builds/linux/GTDZ.x86_64"
