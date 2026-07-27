#!/usr/bin/env python3
"""Convertit un extrait Overpass en mesh 3D (GLB) : bâtiments colorés + routes.

Lit osm/data/<quartier>.json (produit par extract_osm.py) et écrit
osm/data/<quartier>.glb, centré sur la zone, en mètres, axe Y vers le haut.

- Bâtiments : extrusion des empreintes, hauteur = tag `height` ou `building:levels` x 3 m
  (défaut 9 m). Palette de façades type « Alger la Blanche » (blanc cassé, crème, sable),
  répartie par bâtiment. Collisions auto via le suffixe de nœud "-col" (convention Godot).
- Routes : rubans extrudés (6 cm) à partir des ways `highway`, largeur selon le type,
  couleur asphalte.
- Affiche un point de spawn suggéré (sur une route proche du centre) en coordonnées Godot.

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
from shapely.geometry import LineString, Polygon
from shapely.ops import unary_union

DATA_DIR = pathlib.Path(__file__).resolve().parent / "data"
M_PER_DEG_LAT = 110540.0
DEFAULT_HEIGHT = 9.0
LEVEL_HEIGHT = 3.0
MIN_FOOTPRINT_M2 = 4.0

# Palette façades (RGB 0-1) — nuances d'Alger la Blanche (fallback si les
# matériaux à textures ne sont pas appliqués côté Godot).
PALETTE = [
    (0.93, 0.90, 0.84),  # blanc cassé
    (0.89, 0.84, 0.74),  # crème
    (0.85, 0.78, 0.66),  # sable
]

# Catégories de bâtiments (tags OSM) -> familles de textures côté Godot.
CAT_PUBLIC = {
    "church", "mosque", "cathedral", "chapel", "public", "government", "civic",
    "school", "university", "college", "hospital", "train_station", "transportation",
}
CAT_COMMERCIAL = {
    "commercial", "retail", "office", "industrial", "warehouse", "supermarket",
    "hotel", "kiosk",
}


# Monuments exportés comme nœuds dédiés (matériau photo spécifique côté Godot,
# remplacement futur par photogrammétrie — voir docs/04_photogrammetrie_landmarks.md).
LANDMARKS = {
    376558747: "landmark_grande_poste",  # ACTEL la Grande Poste
}


def building_category(tags: dict) -> str:
    b = tags.get("building", "yes")
    if b in CAT_PUBLIC or "historic" in tags or tags.get("amenity") in ("place_of_worship", "townhall"):
        return "pub"
    if b in CAT_COMMERCIAL or "shop" in tags:
        return "com"
    return "res"
ROAD_COLOR = (0.23, 0.23, 0.25)
ROAD_HEIGHT = 0.06

ROAD_WIDTHS = {
    "motorway": 12.0, "trunk": 10.0, "primary": 9.0, "secondary": 8.0,
    "tertiary": 7.0, "residential": 6.0, "unclassified": 6.0,
    "living_street": 5.0, "pedestrian": 5.0, "service": 4.0,
}
SKIP_HIGHWAYS = {
    "footway", "path", "steps", "cycleway", "track", "corridor",
    "bridleway", "construction", "proposed", "platform", "elevator",
}
SPAWN_ROAD_TYPES = {"primary", "secondary", "tertiary", "residential", "pedestrian"}


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


def make_material(rgb: tuple) -> trimesh.visual.material.PBRMaterial:
    return trimesh.visual.material.PBRMaterial(
        baseColorFactor=[rgb[0], rgb[1], rgb[2], 1.0],
        metallicFactor=0.0,
        roughnessFactor=0.95,
    )


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
    highway_ways = [
        e for e in elements
        if e.get("type") == "way" and e.get("tags", {}).get("highway")
        and e["tags"]["highway"] not in SKIP_HIGHWAYS and len(e.get("nodes", [])) >= 2
    ]
    if not building_ways:
        print("Aucun bâtiment exploitable dans l'extrait.", file=sys.stderr)
        return 1

    all_coords = [nodes[n] for w in building_ways for n in w["nodes"] if n in nodes]
    lat0 = sum(c[0] for c in all_coords) / len(all_coords)
    lon0 = sum(c[1] for c in all_coords) / len(all_coords)
    m_per_deg_lon = 111320.0 * math.cos(math.radians(lat0))

    def to_xy(node_id):
        lat, lon = nodes[node_id]
        return ((lon - lon0) * m_per_deg_lon, (lat - lat0) * M_PER_DEG_LAT)

    rotation = trimesh.transformations.rotation_matrix(-np.pi / 2, [1, 0, 0])
    scene = trimesh.Scene()

    # --- Bâtiments, répartis par catégorie OSM x variation ---
    # Noms de nœuds "b_<cat><var>-col" : la scène Godot s'en sert pour assigner
    # les matériaux à textures (voir game/scripts/city_materials.gd).
    buckets: dict[tuple, list] = {}
    skipped = 0
    for way in building_ways:
        coords = [to_xy(n) for n in way["nodes"] if n in nodes]
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
            mesh = trimesh.creation.extrude_polygon(polygon, building_height(way["tags"]))
            if way["id"] in LANDMARKS:
                mesh.apply_transform(rotation)
                mesh.visual = trimesh.visual.TextureVisuals(material=make_material(PALETTE[0]))
                lname = f"{LANDMARKS[way['id']]}-col"
                scene.add_geometry(mesh, node_name=lname, geom_name=lname)
                print(f"  {lname} : nœud monument dédié (way {way['id']})")
                continue
            key = (building_category(way["tags"]), way["id"] % len(PALETTE))
            buckets.setdefault(key, []).append(mesh)
        except Exception:
            skipped += 1

    n_buildings = 0
    for (cat, var), meshes in sorted(buckets.items()):
        n_buildings += len(meshes)
        combined = trimesh.util.concatenate(meshes)
        combined.apply_transform(rotation)
        combined.visual = trimesh.visual.TextureVisuals(material=make_material(PALETTE[var]))
        name = f"b_{cat}{var}-col"
        scene.add_geometry(combined, node_name=name, geom_name=name)
        print(f"  {name} : {len(meshes)} bâtiments")

    # --- Routes ---
    ribbons = []
    for way in highway_ways:
        coords = [to_xy(n) for n in way["nodes"] if n in nodes]
        if len(coords) < 2:
            continue
        width = ROAD_WIDTHS.get(way["tags"]["highway"], 5.0)
        ribbons.append(LineString(coords).buffer(width / 2.0, cap_style=2, join_style=2))
    n_road_polys = 0
    if ribbons:
        merged = unary_union(ribbons)
        geoms = merged.geoms if merged.geom_type == "MultiPolygon" else [merged]
        road_meshes = []
        for geom in geoms:
            if geom.is_empty or geom.geom_type != "Polygon":
                continue
            try:
                road_meshes.append(trimesh.creation.extrude_polygon(geom, ROAD_HEIGHT))
                n_road_polys += 1
            except Exception:
                pass
        if road_meshes:
            roads = trimesh.util.concatenate(road_meshes)
            roads.apply_transform(rotation)
            roads.visual = trimesh.visual.TextureVisuals(material=make_material(ROAD_COLOR))
            scene.add_geometry(roads, node_name="roads", geom_name="roads")

    # --- Spawn suggéré : nœud de route le plus proche du centre ---
    best = None
    for way in highway_ways:
        if way["tags"]["highway"] not in SPAWN_ROAD_TYPES:
            continue
        for n in way["nodes"]:
            if n not in nodes:
                continue
            x, y = to_xy(n)
            d = x * x + y * y
            if best is None or d < best[0]:
                best = (d, x, y)

    out_path = DATA_DIR / f"{args.district}.glb"
    scene.export(out_path)
    print(f"OK : {n_buildings} bâtiments ({skipped} ignorés), {n_road_polys} polygones de route -> {out_path}")
    if best:
        # Repère Godot : X = est, Z = -nord (rotation -90° autour de X appliquée au mesh).
        print(f"Spawn suggéré (Godot) : ({best[1]:.1f}, 1.0, {-best[2]:.1f})")
    print("Copier le .glb dans game/assets/generated/ puis relancer l'import Godot.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
