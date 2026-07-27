#!/usr/bin/env python3
"""Extraction OpenStreetMap via l'API Overpass.

Télécharge bâtiments + routes d'un quartier d'Alger prédéfini et sauvegarde
le JSON brut Overpass dans osm/data/<quartier>.json.

Usage :
    python extract_osm.py alger_centre
    python extract_osm.py casbah
    python extract_osm.py bab_el_oued

Les bounding boxes sont approximatives : à affiner avec https://bboxfinder.com
(format sud, ouest, nord, est) avant les campagnes sérieuses.
"""

import argparse
import json
import pathlib
import sys

import requests

# Plusieurs miroirs : le premier qui répond gagne (l'instance principale
# rejette parfois les clients non identifiés, d'où le User-Agent explicite).
OVERPASS_URLS = [
    "https://overpass-api.de/api/interpreter",
    "https://overpass.kumi.systems/api/interpreter",
    "https://maps.mail.ru/osm/tools/overpass/api/interpreter",
]
HEADERS = {"User-Agent": "GTDZ-city-game/0.1 (projet open source; contact via repo)"}
DATA_DIR = pathlib.Path(__file__).resolve().parent / "data"

# (sud, ouest, nord, est)
DISTRICTS = {
    "alger_centre": (36.765, 3.050, 36.782, 3.068),  # Grande Poste / front de mer
    "casbah": (36.780, 3.055, 36.790, 3.064),
    "bab_el_oued": (36.788, 3.043, 36.800, 3.055),
}

QUERY_TEMPLATE = """
[out:json][timeout:120];
(
  way["building"]({bbox});
  relation["building"]({bbox});
  way["highway"]({bbox});
);
out body;
>;
out skel qt;
"""


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("district", choices=sorted(DISTRICTS))
    args = parser.parse_args()

    bbox = ",".join(str(v) for v in DISTRICTS[args.district])
    query = QUERY_TEMPLATE.format(bbox=bbox)

    print(f"Requête Overpass pour '{args.district}' (bbox {bbox})...")
    payload = None
    last_error: Exception | None = None
    for url in OVERPASS_URLS:
        try:
            response = requests.post(url, data={"data": query}, headers=HEADERS, timeout=180)
            response.raise_for_status()
            payload = response.json()
            print(f"  serveur OK : {url}")
            break
        except Exception as exc:  # on tente le miroir suivant
            print(f"  échec {url} : {exc}")
            last_error = exc
    if payload is None:
        raise SystemExit(f"Tous les serveurs Overpass ont échoué. Dernière erreur : {last_error}")

    elements = payload.get("elements", [])
    n_buildings = sum(
        1 for e in elements if e.get("type") in ("way", "relation") and "building" in e.get("tags", {})
    )
    n_roads = sum(1 for e in elements if e.get("type") == "way" and "highway" in e.get("tags", {}))

    DATA_DIR.mkdir(exist_ok=True)
    out_path = DATA_DIR / f"{args.district}.json"
    out_path.write_text(json.dumps(payload), encoding="utf-8")

    print(f"OK : {n_buildings} bâtiments, {n_roads} tronçons de route -> {out_path}")
    print("Étape suivante : python osm/osm_to_mesh.py " + args.district)
    return 0


if __name__ == "__main__":
    sys.exit(main())
