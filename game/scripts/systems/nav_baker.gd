extends NavigationRegion3D
## Bake le navmesh au chargement de la scène (asynchrone, sur thread) à partir
## des nœuds du groupe "navsource" (ville + sol), limité à la zone jouable
## par filter_baking_aabb. Les ennemis ont un repli en ligne droite tant que
## le bake n'est pas terminé.


func _ready() -> void:
	bake_finished.connect(func(): print("[nav] navmesh prêt (%d polygones)" % navigation_mesh.get_polygon_count()))
	# Au redémarrage de partie, la ressource partagée peut encore être en cours
	# de bake (async) : dans ce cas le résultat du bake précédent s'appliquera.
	if not is_baking():
		call_deferred("bake_navigation_mesh")
