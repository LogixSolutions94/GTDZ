extends VehicleBody3D
## Véhicule conduisible : E pour monter/descendre, ZQSD pour conduire,
## Espace = frein, souris = regard libre.
## Adapté de resources/vehicle/vehicle.gd du GodotFPS-Template de bukkbeek
## (MIT, https://github.com/bukkbeek/GodotFPS-Template) pour le TPS GTDZ :
## autoload Global remplacé par le groupe "player", inputs remappés,
## collision du joueur neutralisée pendant la conduite.

@export var engine_force_value := 120.0
@export var brake_strength := 8.0
@export var steering_limit := 0.45
@export var steering_speed := 3.0
@export var camera_sensitivity := 0.003
@export var camera_pitch_min := -40.0
@export var camera_pitch_max := 60.0

@onready var camera: Camera3D = $Camera3D
@onready var player_exit: Marker3D = $PlayerExit

var player_in_range := false
var is_driving := false
var _steering_input := 0.0
var _cam_yaw := 0.0
var _cam_pitch := 0.0
var _saved_collision_layer := 0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if is_driving:
			_exit_vehicle()
		elif player_in_range:
			_enter_vehicle()
	elif is_driving and event is InputEventMouseMotion \
			and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_cam_yaw -= event.relative.x * camera_sensitivity
		_cam_pitch = clampf(_cam_pitch - event.relative.y * camera_sensitivity,
				deg_to_rad(camera_pitch_min), deg_to_rad(camera_pitch_max))


func _physics_process(delta: float) -> void:
	if not is_driving:
		return
	camera.rotation = Vector3(_cam_pitch, _cam_yaw, 0.0)

	var throttle := Input.get_axis("move_back", "move_forward")
	engine_force = throttle * engine_force_value
	brake = brake_strength if Input.is_action_pressed("jump") else 0.0

	var target_steer := Input.get_axis("move_right", "move_left") * steering_limit
	_steering_input = lerpf(_steering_input, target_steer, steering_speed * delta)
	steering = _steering_input


func _get_player() -> Node:
	return get_tree().get_first_node_in_group("player")


func _enter_vehicle() -> void:
	var player := _get_player()
	if player == null:
		return
	is_driving = true
	_cam_yaw = 0.0
	_cam_pitch = 0.0

	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	player.visible = false
	# Le corps invisible du joueur ne doit pas bloquer le véhicule.
	_saved_collision_layer = player.collision_layer
	player.collision_layer = 0
	player.collision_mask = 0

	camera.make_current()
	engine_force = 0.0
	brake = 0.0
	_steering_input = 0.0
	steering = 0.0


func _exit_vehicle() -> void:
	var player := _get_player()
	if player == null:
		return
	is_driving = false

	player.global_position = player_exit.global_position
	player.visible = true
	player.collision_layer = _saved_collision_layer
	player.collision_mask = 1
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
	player.camera.make_current()

	engine_force = 0.0
	brake = brake_strength
	_steering_input = 0.0
	steering = 0.0


func _on_door_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = true


func _on_door_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
