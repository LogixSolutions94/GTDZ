# Licences des modèles d'armes

Les deux modèles sont sous licence **CC0 1.0 Universal (Public Domain)** — usage commercial,
modification et redistribution autorisés sans attribution obligatoire (attribution fournie
ici par courtoisie). Texte légal complet : `License.txt` (source :
https://creativecommons.org/publicdomain/zero/1.0/legalcode.txt).

## ak47.glb — « AK47 »
- Auteur : Quaternius (https://quaternius.com)
- Pack d'origine : Ultimate Guns Pack (40 modèles, CC0)
- Page du modèle (preuve licence : « Public Domain (CC0) » avec lien
  https://creativecommons.org/publicdomain/zero/1.0/) :
  https://poly.pizza/m/em1Hi9GuCv
- Preuve secondaire (page officielle du pack, « License: CC0 ») :
  https://quaternius.com/packs/ultimategun.html
- Fichier téléchargé : https://static.poly.pizza/cf6f2c6d-87a2-47d5-883f-1efd73900f41.glb
- Aperçu : `ak_preview.jpg`

## smg.glb — « Submachine Gun » (style MP5/UMP, crosse repliable)
- Auteur : Quaternius (https://quaternius.com)
- Pack d'origine : Ultimate Guns Pack (40 modèles, CC0)
- Page du modèle (preuve licence : « Public Domain (CC0) » avec lien
  https://creativecommons.org/publicdomain/zero/1.0/) :
  https://poly.pizza/m/7ehatxr7FY
- Preuve secondaire (bundle officiel Quaternius sur Poly Pizza) :
  https://poly.pizza/bundle/Ultimate-Guns-Pack-cpgUfI4t2F
- Fichier téléchargé : https://static.poly.pizza/fb8ae707-d5b9-4eb8-ab8c-1c78d3c1f710.glb
- Aperçu : `smg_preview.jpg`

## Notes techniques (import Godot 4)
- Format : GLB (glTF binaire v2, généré par FBX2glTF v0.9.7). Matériaux en couleurs plates,
  aucune texture externe.
- ak47.glb : 1 mesh, 1122 triangles, 4 matériaux. Nœud racine « AK » avec rotation -90° X
  et échelle 100. Taille monde ~1.42 x 0.73 x 0.15 m.
- smg.glb : 1 mesh, 1374 triangles, 4 matériaux. Nœud « SubmachineGun_2 », rotation -90° X,
  échelle 100. Taille monde ~4.04 x 1.85 x 0.32 (surdimensionnée : prévoir un scale ~0.2
  dans Godot).
- Origine : ni l'un ni l'autre n'a l'origine exactement au centre géométrique ; elle se situe
  dans la zone poignée/pontet (AK : décalée à ~27 % d'une extrémité, mi-hauteur ; SMG :
  proche du centre horizontal, mi-hauteur). Prévoir un Node3D intermédiaire (offset) pour
  l'alignement précis dans la main (BoneAttachment3D).
