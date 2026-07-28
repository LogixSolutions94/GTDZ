extends Node3D
## Pose les objets placés « à plat » (joueur, véhicules, props, cibles) sur le
## relief réel au chargement de la scène, par lancer de rayon vertical.

const SKIP := ["AlgerCentre", "Mer", "NavRegion", "WaveSpawner", "PedestrianSpawner",
	"WorldEnvironment", "Sun", "GameHUD", "HUD", "GroundSnapper"]


func _ready() -> void:
	_snap.call_deferred()


func _snap() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	var space := get_world_3d().direct_space_state
	var snapped_count := 0
	for child in get_parent().get_children():
		if not (child is Node3D) or child.name in SKIP:
			continue
		var origin: Vector3 = child.global_position + Vector3.UP * 200.0
		var query := PhysicsRayQueryParameters3D.create(origin, origin + Vector3.DOWN * 500.0)
		if child is CollisionObject3D:
			query.exclude = [child.get_rid()]
		var hit := space.intersect_ray(query)
		if hit:
			child.global_position.y = hit.position.y + 0.1
			snapped_count += 1
	print("[relief] %d objets posés sur le terrain" % snapped_count)
