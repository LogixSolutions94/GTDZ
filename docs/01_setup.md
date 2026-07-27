# GTDZ — Guide d'installation pas à pas

Ce guide s'adresse à un humain (le chef de projet) qui installe le projet sur sa machine
Windows et sur le VPS OVH. **Aucun script ne s'exécute tout seul : c'est toi qui les lances.**

## 1. Prérequis

- **PC de dev** : Windows 11, PowerShell, [winget](https://learn.microsoft.com/fr-fr/windows/package-manager/) (inclus dans Windows 11).
- **VPS** : Ubuntu 22.04+ ou Debian 12+, accès SSH avec sudo.
- Un compte GitHub si tu veux héberger le repo (recommandé).

## 2. Récupérer le projet

Le projet vit dans `C:\Users\Kooba\Documents\GitHub\GTDZ`. Si tu pousses le repo sur
GitHub, la récupération sur une autre machine (dont le VPS) se fait par :

```bash
git clone https://github.com/<ton-compte>/GTDZ.git
```

## 3. Installation sur le PC Windows

Ouvre PowerShell **en administrateur** dans le dossier du projet, puis :

```bash
powershell -ExecutionPolicy Bypass -File scripts\install\install_windows.ps1
```

Ce script installe via winget (et ne fait rien d'autre) :

- **Git**
- **Python 3.12** (+ un environnement virtuel `.venv` avec les dépendances de `osm/`)
- **Godot Engine 4.x** (édition standard, GDScript)
- **Blender**

> Si `python` ou `godot` sont introuvables juste après l'installation, **ferme et rouvre
> le terminal** : le PATH n'est rafraîchi qu'à l'ouverture d'une nouvelle session.

## 4. Ouvrir le projet dans Godot

1. Lance **Godot** → « Importer » → sélectionne `game/project.godot` → « Importer & Éditer ».
2. Appuie sur **F5** (ou ▶). Tu dois voir une zone de test : sol, quelques volumes
   représentant des immeubles, et un personnage jouable.
3. Contrôles : **ZQSD/WASD** (touches physiques, donc ZQSD fonctionne tel quel sur clavier
   AZERTY), **souris** pour la caméra, **Espace** pour sauter, **Shift** pour sprinter,
   **Échap** pour libérer/capturer la souris.

## 5. Premier build Windows

1. Une seule fois : dans Godot, menu **Éditeur → Gérer les modèles d'export…** →
   « Télécharger et installer » (ce sont les templates officiels de ta version).
2. Puis :

```bash
powershell -ExecutionPolicy Bypass -File scripts\build\build_windows.ps1
```

Le binaire sort dans `builds\windows\GTDZ.exe`. Si le script ne trouve pas Godot,
définis la variable d'environnement `GODOT_PATH` vers l'exécutable Godot.

## 6. Installation sur le VPS OVH

Connecte-toi en SSH, clone le repo, puis :

```bash
bash scripts/install/install_vps.sh
```

Ce script :

- installe **Docker** (via get.docker.com) s'il est absent, et t'ajoute au groupe `docker`
  (déconnexion/reconnexion SSH nécessaire ensuite) ;
- télécharge les images `barichello/godot-ci:4.7.1` (builds) et `colmap/colmap` (photogrammétrie) ;
- **compile l'image OpenMVS** (`gtdz/openmvs`) — compte 20 à 40 minutes, une seule fois.

### Build headless sur le VPS

```bash
bash scripts/build/build_linux_headless.sh
```

Sortie : `builds/linux/GTDZ.x86_64`.

### Photogrammétrie sur le VPS

1. Envoie un lot de photos depuis le PC :

```bash
scp -r ./photos_grande_poste user@vps:~/GTDZ/photogrammetry/input/grande_poste
```

2. Lance le pipeline (compte plusieurs heures pour 100–300 photos, tout en CPU) :

```bash
bash photogrammetry/scripts/run_photogrammetry.sh grande_poste
```

3. Rapatrie le résultat (`photogrammetry/output/grande_poste/`) et ouvre le mesh texturé
   dans Blender pour nettoyage. Consignes de prise de vue : [photogrammetry/README.md](../photogrammetry/README.md).

## 7. Générer un quartier basse fidélité depuis OpenStreetMap

Sur le PC (après l'étape 3) :

```bash
.venv\Scripts\python.exe osm\extract_osm.py alger_centre
```

```bash
.venv\Scripts\python.exe osm\osm_to_mesh.py alger_centre
```

Le premier télécharge bâtiments + rues du quartier (bbox prédéfinie, ajustable dans le
script) ; le second produit `osm/data/alger_centre.glb`. Copie ce fichier dans
`game/assets/generated/`, puis dans Godot : clic sur le `.glb` importé → onglet « Import » →
active la génération de collisions (ou instancie-le dans une scène et ajoute un
`StaticBody3D`). La phase 1 de la roadmap automatisera cette intégration.

## 8. Dépannage

| Symptôme | Cause / remède |
|---|---|
| `winget` introuvable | Installer « App Installer » depuis le Microsoft Store |
| `python` introuvable après install | Rouvrir le terminal (PATH), ou utiliser `py -3.12` |
| `docker: permission denied` sur le VPS | Se déconnecter/reconnecter après `install_vps.sh` (groupe docker) |
| Export Godot échoue « No export template » | Étape 5.1 non faite (télécharger les templates) |
| Preset « Linux » introuvable au build | Version Godot < 4.3 : renommer la plateforme en « Linux/X11 » dans `game/export_presets.cfg` |
| Overpass renvoie une erreur 429 | Trop de requêtes : attendre une minute et relancer |
