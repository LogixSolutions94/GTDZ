# GTDZ — Plan de production (mode studio)

*Rédigé le 28/07/2026. Organisation calquée sur une équipe de dev : chaque « département »
est un rôle que Claude endosse tour à tour ; [PC] = bloqué par le futur PC à GPU dédié,
[Kooba] = action du chef de projet.*

## Jalons

| Jalon | Définition | État |
|---|---|---|
| **Prototype** | Marcher dans Alger-Centre généré | ✅ fait |
| **Alpha** (en cours) | Boucle de jeu complète + ville crédible + jeu « qui se lance comme un jeu » (menu, pause) | ~80 % |
| **Beta** | Contenu complet : piétons, sons complets, équilibrage, 3 monuments, optimisation, tutoriel | — |
| **1.0** | Beta + polish graphique Forward+ [PC], build distribué (itch.io ?), page de crédits in-game | — |

## Backlog par département

### 🎨 Direction artistique / Environnement
- [x] Ciel HDRI, normal maps, façades procédurales, trottoirs, props, 2 monuments photo
- [ ] Étalonnage image (contraste/saturation) — **cette itération**
- [ ] Auvents + climatiseurs sur façades hero zone (props importés)
- [ ] Passages piétons aux carrefours (road-crossing.glb)
- [ ] Embrasures de fenêtres 3D sur la hero zone
- [ ] 3e monument (Djamaa el Djedid ou Sacré-Cœur, photos inventoriées)
- [ ] [PC] Bascule Forward+ : GI, SSAO, ombres douces, reflets (1 ligne, préparée)

### 🚶 Monde vivant
- [ ] Piétons sur les trottoirs (navmesh, anim Walk/Idle) — **cette itération**
- [ ] Personnages piétons variés (pack Quaternius CC0, ~50 modèles même rig) [Kooba : rien]
- [ ] Trafic automobile simple (godot-road-generator MIT identifié)
- [ ] Sons d'ambiance ville (klaxons lointains, oiseaux — sources CC0 à inventorier)

### 🔫 Gameplay
- [x] Tir/visée/rechargement, IA 3 états, vagues, score, game over/respawn
- [ ] Munitions à ramasser sur les ennemis — **cette itération**
- [ ] Recul de tir + confirmation d'impact (feel) — **cette itération**
- [ ] 2e arme (architecture WeaponResource de chafmere, MIT)
- [ ] Ennemis variés (tireur embusqué, rusheur) ; boss de vague 5/10
- [ ] Conduite jeep : réglage + son moteur [retour Kooba attendu]

### 🖥️ UI/UX
- [x] HUD (vie, munitions, score, vague), écran game over
- [ ] Menu principal + menu pause — **cette itération**
- [ ] Options (sensibilité souris, plein écran, volume)
- [ ] Écran de crédits in-game (obligation légale OSM/CC-BY déjà en HUD)

### 🔧 Tech / Perfs / QA
- [x] Capture d'écran automatisée + hooks de test (kill-player, kill-enemies…)
- [x] Builds VPS (Linux) ; [ ] build Windows distribué (templates export [Kooba : 1 clic])
- [ ] Streaming de quartiers pour Casbah/Bab El Oued (pattern OpenLiberty, phase 2)
- [ ] Suite de tests de non-régression sur les hooks existants

## Prochaine session type (si tout va bien)
1. Retour visuel/gameplay de Kooba sur cette itération.
2. Auvents + passages piétons + 3e monument (art) OU 2e arme + ennemis variés (gameplay) — au choix du chef de projet.
