#!/usr/bin/env python3
"""Convertit un extrait Overpass en mesh 3D (GLB) par extrusion des empreintes de bâtiments.

Lit osm/data/<quartier>.json (produit par extract_osm.py) et écrit
osm/data/<quartier>.glb, centré sur le milieu de la zone, en mètres, axe Y vers le haut
(convention glTF/Godot).

Hauteur des bâtiments : tag OSM `height`, sinon `building:levels` x 3 m, sinon 9 m.

Usage :
    python osm_to_mesh.py alger_centre
"""

import argparse
import json
import math
import pathlib
import sys

import numpy as np
import trimesh
from shapely.geometry import Polygon

DATA_DIR = pathlib.Path(__file__).resolve().parent / "data"
M_PER_DEG_LAT = 110540.0
DEFAULT_HEIGHT = 9.0
LEVEL_HEIGHT = 3.0
MIN_FOOTPRINT_M2 = 4.0


def building_height(tags: dict) -> float:
    raw_height = tags.get("height")
    if raw_height is not None:
        try:
            return float(str(raw_height).lower().replace("m", "").strip())
        except ValueError:
            pass
    levels = tags.get("building:levels")
    if levels is not None:
        try:
            return float(levels) * LEVEL_HEIGHT
        except ValueError:
            pass
    return DEFAULT_HEIGHT


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("district")
    args = parser.parse_args()

    in_path = DATA_DIR / f"{args.district}.json"
    if not in_path.exists():
        print(f"Fichier introuvable : {in_path} (lancer d'abord extract_osm.py)", file=sys.stderr)
        return 1

    payload = json.loads(in_path.read_text(encoding="utf-8"))
    elements = payload.get("elements", [])

    nodes = {e["id"]: (e["lat"], e["lon"]) for e in elements if e.get("type") == "node"}
    building_ways = [
        e for e in elements
        if e.get("type") == "way" and "building" in e.get("tags", {}) and len(e.get("nodes", [])) >= 4
    ]
    if not building_ways:
        print("Aucun bâtiment exploitable dans l'extrait.", file=sys.stderr)
        return 1

    all_lats = [nodes[n][0] for w in building_ways for n in w["nodes"] if n in nodes]
    all_lons = [nodes[n][1] for w in building_ways for n in w["nodes"] if n in nodes]
    lat0, lon0 = sum(all_lats) / len(all_lats), sum(all_lons) / len(all_lons)
    m_per_deg_lon = 111320.0 * math.cos(math.radians(lat0))

    meshes = []
    skipped = 0
    for way in building_ways:
        coords = []
        for node_id in way["nodes"]:
            if node_id not in nodes:
                continue
            lat, lon = nodes[node_id]
            coords.append(((lon - lon0) * m_per_deg_lon, (lat - lat0) * M_PER_DEG_LAT))
        if len(coords) < 4:
            skipped += 1
            continue
        polygon = Polygon(coords)
        if not polygon.is_valid:
            polygon = polygon.buffer(0)
        if polygon.is_empty or polygon.area < MIN_FOOTPRINT_M2 or polygon.geom_type != "Polygon":
            skipped += 1
            continue
        try:
            meshes.append(trimesh.creation.extrude_polygon(polygon, building_height(way["tags"])))
        except Exception:
            skipped += 1

    if not meshes:
        print("Aucun mesh généré.", file=sys.stderr)
        return 1

    city = trimesh.util.concatenate(meshes)
    # trimesh extrude en Z-up ; glTF (et Godot) sont Y-up.
    city.apply_transform(trimesh.transformations.rotation_matrix(-np.pi / 2, [1, 0, 0]))

    # Nom de nœud suffixé "-col" : convention d'import Godot qui génère
    # automatiquement une collision trimesh statique sur ce mesh.
    scene = trimesh.Scene()
    scene.add_geometry(city, node_name="buildings-col", geom_name="buildings-col")

    out_path = DATA_DIR / f"{args.district}.glb"
    scene.export(out_path)
    extent = city.bounds[1] - city.bounds[0]
    print(f"OK : {len(meshes)} bâtiments extrudés ({skipped} ignorés) -> {out_path}")
    print(f"Emprise : {extent[0]:.0f} m x {extent[2]:.0f} m, hauteur max {extent[1]:.0f} m")
    print("Copier le .glb dans game/assets/generated/ puis l'importer dans Godot (voir docs/01_setup.md §7).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
