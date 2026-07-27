# Import d'un personnage jouable (Mixamo ou Quaternius CC0)

*Le contrôleur du jeu ([player.gd](../game/scripts/player.gd)) joue les animations **par
nom** (recherche par suffixe : `Idle`, `Walk`, `Run`, `Jump`) sur l'AnimationPlayer du
modèle. Aucun retargeting n'est nécessaire tant que le personnage arrive avec ses propres
animations — c'est le cas des deux options ci-dessous.*

## Option A — Mixamo (proportions réalistes, compte Adobe requis)

### Ce que TU fais (10 minutes, une seule fois)

1. Va sur https://www.mixamo.com et connecte-toi avec ton compte Adobe.
2. Onglet **Characters** : choisis un personnage humain réaliste
   (ex. « Remy », « Brian », « Sophie » — évite les monstres/armures).
3. Onglet **Animations** : cherche et télécharge, l'une après l'autre, avec le
   personnage sélectionné :

   | Animation Mixamo | Réglages export |
   |---|---|
   | `Idle` (ou "Breathing Idle") | Format **FBX Binary**, Skin **With Skin**, 30 fps |
   | `Walking` | **coche "In Place"** ✔, With Skin, 30 fps |
   | `Running` | **coche "In Place"** ✔, With Skin, 30 fps |
   | `Jump` | With Skin, 30 fps |

   > « In Place » est crucial pour Walking/Running : sans ça, l'animation déplace le
   > personnage toute seule et il glissera dans le jeu.

4. Dépose les 4 fichiers `.fbx` dans : `game/assets/characters/mixamo/`
   (crée le dossier s'il n'existe pas), puis **dis-moi que c'est fait**.

### Ce que JE fais ensuite (automatique)

- Import des FBX (Godot 4.7 lit le FBX nativement), fusion des 4 animations dans un
  seul AnimationPlayer avec les noms `Idle` / `Walk` / `Run` / `Jump`.
- Remplacement du Quaternius chibi dans `player.tscn` (nœud `Skin`).
- Recalage caméra pour une taille humaine 1,80 m : hauteur d'yeux du pivot ≈ 1,55 m,
  bras de caméra ≈ 3,5 m, capsule de collision ajustée.
- Orientation du modèle (les exports Mixamo regardent parfois +Z au lieu de -Z : je
  corrige d'un demi-tour si besoin — je le vois sur capture d'écran).
- Mise à jour de CREDITS.md (« Personnage et animations : Adobe Mixamo »).

### Note licence (décision chef de projet du 28/07/2026)

La FAQ Adobe autorise l'usage illimité, commercial inclus, dans un jeu ; la restriction
porte sur la redistribution des assets Mixamo « en pack » hors d'un jeu. L'interprétation
retenue (par le chef de projet) : intégrés au projet Godot, ces fichiers font partie du
jeu → OK pour le repo public. Si un doute survenait plus tard, le fallback est l'option B
(CC0, zéro ambiguïté) et les fichiers Mixamo sortiraient du repo.

## Option B (plan B, 100 % CC0) — Quaternius Universal Animation Library

- Personnages aux proportions normales (~7 têtes) avec une grande bibliothèque
  d'animations partagées, CC0 pur : redistribuable sans aucune restriction.
- Téléchargeable sans compte (site quaternius.com / miroir GitHub CC0) — recherche et
  téléchargement en cours par agent ; intégration identique à l'option A (mêmes
  noms d'animations, même nœud `Skin`).
- Moins « réaliste » visuellement que Mixamo (low-poly propre), mais cohérent avec
  un rendu léger sur la machine de dev actuelle.

## Check-list de validation (dans les deux cas)

1. Le personnage a des proportions humaines (~1,80 m dans le jeu, comparer aux portes).
2. Idle à l'arrêt, marche/course selon la vitesse, saut sur Espace, sans glissement.
3. La caméra épaule ne coupe pas la tête et ne traverse pas les murs des rues étroites.
4. CREDITS.md à jour.
