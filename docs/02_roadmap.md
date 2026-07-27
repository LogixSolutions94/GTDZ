# GTDZ — Roadmap par phases

Principe : avancer doucement, avec un livrable jouable à chaque phase.
Pour chaque tâche : **[auto]** = réalisable par Claude (code, scènes, scripts),
**[manuel]** = à faire par le chef de projet (photos, validations, exécution de scripts lourds).

## Phase 0 — Prototype technique ✅ (mise en place faite, validation à faire)

**Objectif : vérifier que toute la chaîne fonctionne.**

- [x] Structure de repo, projet Godot squelette, personnage 3e personne jouable **[auto]**
- [x] Scripts d'installation Windows + VPS, scripts de build headless **[auto]**
- [x] Outils installés sur le PC : Python 3.12, Godot 4.7.1, Blender (27/07/2026) **[auto]**
- [x] Extraction OSM d'Alger-Centre : 1 559 bâtiments, 1 064 routes → mesh GLB (1,4 × 2 km) **[auto]**
- [x] Quartier intégré dans Godot avec collisions (`city_test.tscn`), import headless validé sans erreur **[auto]**
- [ ] Ouvrir le projet dans Godot sur le PC, valider visuellement les contrôles **[manuel]**
      (raccourcis « GTDZ - Jouer » et « GTDZ - Editeur Godot » créés sur le bureau le 27/07/2026)
- [x] VPS installé (27/07/2026) : repo cloné dans `/home/claude-agent/GTDZ`, images Docker
      godot-ci 4.7.1 + COLMAP en place, **premier build Linux réussi** (`builds/linux/GTDZ.x86_64`, 72 Mo).
      Image OpenMVS en compilation. Note : le VPS a 8 vCores (pas 12) et héberge Odoo → compilations bridées (nice + 4 cœurs) **[auto]**
- [x] Repo GitHub public créé et poussé : https://github.com/LogixSolutions94/GTDZ **[auto]**

**Livrable : le jeu se lance sur PC, un build sort du VPS.**

> Note machine de dev (27/07/2026) : laptop i5-8250U + Intel UHD 620 + 12 Go RAM, sans GPU
> dédié → renderer Godot passé en `gl_compatibility`, photogrammétrie impossible en local
> (pas de CUDA) donc 100 % sur le VPS. Voir docs/00_architecture.md et la discussion PC fixe.

## Phase 1 — Quartier pilote : Front de mer / Alger-Centre

**Objectif : marcher dans un Alger-Centre reconnaissable.**

- [ ] Affiner la bbox du quartier (Grande Poste ↔ front de mer) **[manuel, 10 min avec bboxfinder]**
- [ ] Génération basse fidélité : OSM → GLB → scène Godot avec collisions et routes marquées **[auto]**
- [ ] Script d'import automatisé (GLB → scène avec StaticBody3D + navmesh) **[auto]**
- [ ] Campagne photo n°1 : façades de la Grande Poste et d'un îlot du front de mer,
      en suivant [photogrammetry/README.md](../photogrammetry/README.md) **[manuel]**
- [ ] Traitement photogrammétrie sur le VPS (lots de 100–300 photos) **[manuel : lancer le script ; auto : ajustements]**
- [ ] Nettoyage Blender : décimation, suppression passants/voitures, LOD ; je fournis
      les scripts Blender (Python) de décimation par lots **[auto + manuel pour l'œil artistique]**
- [ ] Remplacement progressif des boîtes grises par les meshes texturés **[auto]**
- [ ] Éclairage/ambiance : soleil méditerranéen, ciel, brume légère **[auto]**

**Livrable : exploration à pied du quartier pilote, textures réelles sur les bâtiments clés.**

## Phase 2 — Extension : La Casbah et Bab El Oued

**Objectif : trois quartiers reliés, perfs maîtrisées.**

- [ ] Extraction OSM + basse fidélité des deux quartiers **[auto]**
- [ ] Découpage en scènes streamées (chargement/déchargement par zone) **[auto]**
- [ ] Système de LOD et occlusion culling réglés (la Casbah, dense et en pente, est le cas difficile) **[auto]**
- [ ] Campagnes photos Casbah + Bab El Oued **[manuel]**
- [ ] Passage à Git LFS si les assets dépassent ~1 Go **[auto config, manuel validation]**
- [ ] Cible perfs : 60 fps sur le PC de dev, budget mémoire < 8 Go **[auto profiling]**

**Livrable : circulation continue entre les trois quartiers.**

## Phase 3 — Gameplay tir / arcade

**Objectif : transformer la visite en jeu.**

- [ ] Game design court (1 page) : mode arcade (vagues ? courses ? scoring ?) à valider **[manuel sur proposition auto]**
- [ ] Visée épaule + tir (raycast), caméra TPS affinée **[auto]**
- [ ] Ennemis : navigation (navmesh), IA simple (patrouille/poursuite/couverture) **[auto]**
- [ ] HUD : santé, munitions, score, minimap du quartier **[auto]**
- [ ] Sons (bibliothèques libres type freesound/CC0) et impacts **[auto + manuel choix artistique]**
- [ ] Boucle de jeu : spawn, vagues, score, game over, restart **[auto]**
- [ ] Playtests et équilibrage **[manuel]**

**Livrable : mini-jeu de tir arcade complet dans Alger-Centre, extensible aux autres quartiers.**

## Plus tard (hors périmètre v1)

- Backend multijoueur / leaderboards sur le VPS.
- Export web (Godot HTML5) d'une zone réduite en vitrine.
- Véhicules, trafic, piétons.
- Migration éventuelle vers Unreal si ambition AAA (voir §8 de l'architecture).
