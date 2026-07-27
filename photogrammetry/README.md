# Photogrammétrie — organisation et consignes de prise de vue

## Organisation

```
photogrammetry/
├── input/<dataset>/    # photos brutes d'un lot (ex. input/grande_poste/)
├── output/<dataset>/   # résultats générés (colmap/, mvs/)
└── scripts/run_photogrammetry.sh
```

Un **dataset** = un lot cohérent de photos d'un même bâtiment/îlot (ex. `grande_poste`,
`front_de_mer_ilot1`). Petit et cohérent vaut mieux que gros et hétérogène.

## Consignes de prise de vue (important : la qualité du mesh se joue ici)

- **Recouvrement 70–80 %** entre photos successives : avancer par petits pas latéraux,
  chaque photo doit partager la majorité de son contenu avec la précédente.
- **Tourner autour** du sujet quand c'est possible (façade : balayage en arc, plusieurs hauteurs).
- **Focale fixe** (pas de zoom en cours de session), exposition stable, pas de flash.
- **Lumière diffuse** : ciel voilé ou début/fin de journée. Éviter le plein soleil de midi
  (ombres dures = artefacts) et les surfaces vitrées/réfléchissantes.
- **Résolution maximale** de l'appareil, photos nettes (vérifier sur place).
- Éviter les éléments mobiles (piétons, voitures) : ils créent des fantômes dans le mesh
  et posent des questions de **droit à l'image** — flouter visages et plaques si besoin.
- **Drones : strictement réglementés en Algérie** (autorisation préalable obligatoire).
  Le pipeline est prévu pour des photos au sol.
- Volume conseillé par dataset : **100 à 300 photos** (au-delà, le traitement CPU sur le
  VPS devient très long ; découper en plusieurs datasets).

## Traitement

Voir [docs/01_setup.md](../docs/01_setup.md) §6 : envoi des photos sur le VPS par `scp`,
puis `bash photogrammetry/scripts/run_photogrammetry.sh <dataset>`.

Matcher : `exhaustive` (défaut) pour un lot < ~500 photos ; `sequential` si les photos ont
été prises dans l'ordre en marchant (plus rapide).

## Alternative locale avec GPU NVIDIA

Si le PC de dev a une carte NVIDIA, **Meshroom** (open source, GUI) est plus simple et
plus rapide que le pipeline CPU : glisser les photos, lancer, récupérer le mesh texturé.
Le VPS reste utile pour les gros lots pendant que le PC sert à autre chose.
