#!/usr/bin/env python3
"""Récupère l'altitude réelle (SRTM 30 m via opentopodata.org) sur une grille
couvrant le quartier, pour donner à la ville son vrai relief.

Usage : python fetch_dem.py alger_centre
Sortie : osm/data/<quartier>_dem.json  {lats, lons, grid[la][lo]}
"""

import json
import pathlib
import sys
import time

import requests

from extract_osm import DISTRICTS

DATA_DIR = pathlib.Path(__file__).resolve().parent / "data"
API = "https://api.opentopodata.org/v1/srtm30m"
GRID = 40      # 40x40 points
MARGIN = 0.004  # ~400 m de marge autour de la bbox


def main() -> int:
    district = sys.argv[1] if len(sys.argv) > 1 else "alger_centre"
    south, west, north, east = DISTRICTS[district]
    south -= MARGIN
    west -= MARGIN
    north += MARGIN
    east += MARGIN

    lats = [south + (north - south) * i / (GRID - 1) for i in range(GRID)]
    lons = [west + (east - west) * j / (GRID - 1) for j in range(GRID)]
    points = [(la, lo) for la in lats for lo in lons]

    elevations: list = []
    for i in range(0, len(points), 100):
        batch = points[i:i + 100]
        locations = "|".join(f"{la:.6f},{lo:.6f}" for la, lo in batch)
        for attempt in range(3):
            resp = requests.post(API, data={"locations": locations}, timeout=60,
                                 headers={"User-Agent": "GTDZ-city-game/0.1"})
            if resp.status_code == 200:
                break
            time.sleep(3.0)
        resp.raise_for_status()
        for r in resp.json()["results"]:
            elevations.append(r["elevation"] if r["elevation"] is not None else 0.0)
        print(f"  {min(i + 100, len(points))}/{len(points)} points...")
        time.sleep(1.1)  # limite de courtoisie de l'API (1 req/s)

    grid = [[elevations[i * GRID + j] for j in range(GRID)] for i in range(GRID)]
    out = DATA_DIR / f"{district}_dem.json"
    out.write_text(json.dumps({"lats": lats, "lons": lons, "grid": grid}), encoding="utf-8")
    flat = [v for row in grid for v in row]
    print(f"OK : grille {GRID}x{GRID}, altitudes {min(flat):.0f} à {max(flat):.0f} m -> {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
