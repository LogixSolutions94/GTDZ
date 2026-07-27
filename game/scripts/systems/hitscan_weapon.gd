class_name HitscanWeapon
extends Node
## Arme hitscan TPS : tire depuis le centre de la caméra (visée épaule).
## Logique inspirée des templates FPS open source de la communauté Godot
## (Kenney Starter Kit FPS, MIT), réécrite pour une caméra 3e personne.

signal ammo_changed(in_mag: int, reserve: int)

@export var damage := 25.0
@export var fire_interval := 0.13
@export var mag_size := 30
@export var reserve := 120
@export var spread_deg := 0.6
@export var max_range := 400.0
@export var reload_time := 1.2

var in_mag: int
var _cooldown := 0.0
var _reloading := false


func _ready() -> void:
	in_mag = mag_size


func _process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)


func try_fire(camera: Camera3D) -> void:
	if _cooldown > 0.0 or _reloading:
		return
	if in_mag <= 0:
		reload()
		return
	_cooldown = fire_interval
	in_mag -= 1
	ammo_changed.emit(in_mag, reserve)

	var center := camera.get_viewport().get_visible_rect().size / 2.0
	var from := camera.project_ray_origin(center)
	var dir := camera.project_ray_normal(center)
	dir = dir.rotated(camera.global_basis.y, deg_to_rad(randf_range(-spread_deg, spread_deg)))
	dir = dir.rotated(camera.global_basis.x, deg_to_rad(randf_range(-spread_deg, spread_deg)))

	var query := PhysicsRayQueryParameters3D.create(from, from + dir * max_range)
	var body := get_parent() as CollisionObject3D
	if body:
		query.exclude = [body.get_rid()]
	var hit := camera.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	_spawn_impact(hit.position, hit.normal)
	var target: Object = hit.collider
	if target is Node and target.has_node("Health"):
		target.get_node("Health").take_damage(damage)


func reload() -> void:
	if _reloading or in_mag == mag_size or reserve <= 0:
		return
	_reloading = true
	await get_tree().create_timer(reload_time).timeout
	var take: int = mini(mag_size - in_mag, reserve)
	in_mag += take
	reserve -= take
	_reloading = false
	ammo_changed.emit(in_mag, reserve)


func _spawn_impact(pos: Vector3, normal: Vector3) -> void:
	var marker := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.05
	sphere.height = 0.1
	marker.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.12, 0.1, 0.09)
	marker.material_override = mat
	get_tree().current_scene.add_child(marker)
	marker.global_position = pos + normal * 0.03
	get_tree().create_timer(6.0).timeout.connect(marker.queue_free)
