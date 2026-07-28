class_name Enemy
extends CharacterBody3D
## Ennemi : PATROL -> (zone de détection + ligne de vue) -> CHASE (NavigationAgent3D,
## repli en ligne droite si le navmesh n'est pas prêt) -> ATTACK (hitscan peu précis).
## Pattern inspiré de enemy.gd du GodotFPS-Template de bukkbeek (MIT), restructuré
## en machine à états.

enum State { PATROL, CHASE, ATTACK }

@export var patrol_offsets: Array[Vector3] = [Vector3(10, 0, 0), Vector3(10, 0, 8), Vector3(0, 0, 8)]
@export var patrol_speed := 2.5
@export var chase_speed := 4.5
@export var pause_time := 2.0
@export var attack_range := 13.0
@export var attack_interval := 1.5
@export var attack_damage := 8.0
@export var attack_spread_deg := 3.0
@export var lose_target_distance := 60.0

var state: State = State.PATROL
var _player: Node3D = null
var _player_in_zone := false
var _detected := false
var _patrol_targets: Array[Vector3] = []
var _patrol_index := 0
var _pause := 0.0
var _attack_cooldown := 0.0
var _los_timer := 0.0

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var health: Health = $Health
@onready var collision: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	_patrol_targets.append(global_position)
	for offset in patrol_offsets:
		_patrol_targets.append(global_position + offset)
	health.died.connect(_on_died)
	# Se faire tirer dessus révèle le joueur, même hors zone de détection.
	health.changed.connect(func(_c: float, _m: float):
		_set_detected(true)
		var hurt := get_node_or_null("HurtSound")
		if hurt:
			hurt.play())
	_player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if health.current <= 0.0 or _player == null:
		return
	# Pendant l'écran de game over, l'IA se fige (pas de tir sur un joueur mort).
	if Game.state != Game.GameState.PLAYING:
		velocity.x = 0.0
		velocity.z = 0.0
		return
	if not is_on_floor():
		velocity += get_gravity() * delta
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	_los_timer -= delta
	if _los_timer <= 0.0:
		_los_timer = 0.25
		_update_detection()
	match state:
		State.PATROL:
			_patrol(delta)
		State.CHASE:
			_chase(delta)
		State.ATTACK:
			_attack(delta)
	move_and_slide()


func _set_detected(value: bool) -> void:
	if value and not _detected:
		_detected = true
		state = State.CHASE
	elif not value:
		_detected = false
		state = State.PATROL


func _update_detection() -> void:
	if _detected:
		if global_position.distance_to(_player.global_position) > lose_target_distance:
			_set_detected(false)
		return
	if _player_in_zone and _has_line_of_sight():
		_set_detected(true)


func _has_line_of_sight() -> bool:
	var from := global_position + Vector3.UP * 1.6
	var to := _player.global_position + Vector3.UP * 1.2
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and hit.collider == _player


func _patrol(delta: float) -> void:
	if _pause > 0.0:
		_pause -= delta
		velocity.x = 0.0
		velocity.z = 0.0
		return
	var target := _patrol_targets[_patrol_index]
	if global_position.distance_to(target) < 1.2:
		_pause = pause_time
		_patrol_index = (_patrol_index + 1) % _patrol_targets.size()
		return
	_move_towards(target, patrol_speed, delta)


func _chase(delta: float) -> void:
	var dist := global_position.distance_to(_player.global_position)
	if dist < attack_range and _has_line_of_sight():
		state = State.ATTACK
		return
	agent.target_position = _player.global_position
	var next := agent.get_next_path_position()
	if agent.is_navigation_finished() or next.distance_to(global_position) < 0.05:
		next = _player.global_position  # repli si navmesh indisponible
	_move_towards(next, chase_speed, delta)


func _attack(delta: float) -> void:
	var dist := global_position.distance_to(_player.global_position)
	if dist > attack_range * 1.3 or not _has_line_of_sight():
		state = State.CHASE
		return
	velocity.x = 0.0
	velocity.z = 0.0
	_face(_player.global_position, delta)
	if _attack_cooldown <= 0.0:
		_attack_cooldown = attack_interval
		_fire()


func _fire() -> void:
	var from := global_position + Vector3.UP * 1.6
	var dir := (_player.global_position + Vector3.UP * 1.0 - from).normalized()
	dir = dir.rotated(Vector3.UP, deg_to_rad(randf_range(-attack_spread_deg, attack_spread_deg)))
	var side := dir.cross(Vector3.UP).normalized()
	dir = dir.rotated(side, deg_to_rad(randf_range(-attack_spread_deg, attack_spread_deg)))
	var query := PhysicsRayQueryParameters3D.create(from, from + dir * 120.0)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	var sound := get_node_or_null("ShotSound")
	if sound:
		sound.play()
	if hit.is_empty():
		return
	var target: Object = hit.collider
	if target is Node and target.has_node("Health"):
		target.get_node("Health").take_damage(attack_damage)


func _move_towards(target: Vector3, speed: float, delta: float) -> void:
	var dir := target - global_position
	dir.y = 0.0
	if dir.length() < 0.05:
		return
	dir = dir.normalized()
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	_face(global_position + dir, delta)


func _face(point: Vector3, delta: float) -> void:
	var to := point - global_position
	if Vector2(to.x, to.z).length_squared() > 0.001:
		rotation.y = lerp_angle(rotation.y, atan2(to.x, to.z), 8.0 * delta)


func _on_died() -> void:
	Game.add_score(10)
	set_physics_process(false)
	collision.set_deferred("disabled", true)
	var death := get_node_or_null("DeathSound")
	if death:
		death.play()
	var tween := create_tween()
	tween.tween_property(self, "rotation:x", -PI / 2.0, 0.4)
	tween.tween_interval(2.0)
	tween.tween_callback(queue_free)


func _on_detection_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_in_zone = true


func _on_detection_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_in_zone = false
