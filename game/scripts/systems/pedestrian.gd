extends CharacterBody3D
## Piéton : erre sur le navmesh (trottoirs, places), alterne marche et pause.

@export var walk_speed := 1.7
@export var wander_radius := 90.0

var _idle_time := 0.0

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var skin: Node3D = $Skin

var _anim: AnimationPlayer = null
var _anim_walk := &""
var _anim_idle := &""


func _ready() -> void:
	_anim = skin.find_child("AnimationPlayer", true, false)
	if _anim:
		for anim_name in _anim.get_animation_list():
			var lower := String(anim_name).to_lower()
			if _anim_walk == &"" and lower.ends_with("walk"):
				_anim_walk = anim_name
			elif _anim_idle == &"" and lower.ends_with("idle"):
				_anim_idle = anim_name
	_idle_time = randf_range(0.5, 3.0)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if _idle_time > 0.0:
		_idle_time -= delta
		velocity.x = 0.0
		velocity.z = 0.0
		_play(_anim_idle)
		if _idle_time <= 0.0:
			_pick_new_target()
	elif agent.is_navigation_finished():
		_idle_time = randf_range(2.0, 6.0)
	else:
		var next := agent.get_next_path_position()
		var dir := next - global_position
		dir.y = 0.0
		if dir.length() > 0.05:
			dir = dir.normalized()
			velocity.x = dir.x * walk_speed
			velocity.z = dir.z * walk_speed
			# Le modèle Quaternius regarde vers -Z (même correction que le joueur).
			skin.rotation.y = lerp_angle(skin.rotation.y, atan2(-dir.x, -dir.z), 6.0 * delta)
			_play(_anim_walk)
	move_and_slide()


func _pick_new_target() -> void:
	var map := get_world_3d().navigation_map
	for i in 8:
		var point := NavigationServer3D.map_get_random_point(map, 1, false)
		if point != Vector3.ZERO and point.distance_to(global_position) < wander_radius:
			agent.target_position = point
			return
	# Repli : petit déplacement local aléatoire.
	agent.target_position = global_position + Vector3(randf_range(-15, 15), 0, randf_range(-15, 15))


func _play(anim_name: StringName) -> void:
	if _anim and anim_name != &"" and _anim.current_animation != String(anim_name):
		_anim.play(anim_name, 0.25)
