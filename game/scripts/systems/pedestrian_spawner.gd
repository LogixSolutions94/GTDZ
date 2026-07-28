extends Node3D
## Fait apparaître des piétons sur le navmesh une fois celui-ci prêt,
## en privilégiant les environs de la place de la Grande Poste.

const PEDESTRIAN := preload("res://scenes/npc/pedestrian.tscn")

@export var count := 14
@export var hero_center := Vector3(415, 0, 80)
@export var hero_radius := 140.0


func _ready() -> void:
	_spawn_when_ready.call_deferred()


func _spawn_when_ready() -> void:
	var map := get_world_3d().navigation_map
	# Attend que le navmesh soit baké (quelques secondes en asynchrone).
	for attempt in 30:
		await get_tree().create_timer(1.0).timeout
		if NavigationServer3D.map_get_random_point(map, 1, false) != Vector3.ZERO:
			break
	var spawned := 0
	var tries := 0
	while spawned < count and tries < count * 20:
		tries += 1
		var point := NavigationServer3D.map_get_random_point(map, 1, false)
		if point == Vector3.ZERO:
			continue
		# 3/4 des piétons près de la hero zone, le reste n'importe où.
		if spawned % 4 != 0 and point.distance_to(hero_center) > hero_radius:
			continue
		var pedestrian := PEDESTRIAN.instantiate()
		add_child(pedestrian)
		pedestrian.global_position = point + Vector3.UP * 0.3
		spawned += 1
	print("[piétons] %d apparus" % spawned)
