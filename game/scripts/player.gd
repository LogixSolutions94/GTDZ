extends CharacterBody3D
## Contrôleur 3e personne type GTA (phase 1).
## Caméra orbitale (pivot + SpringArm anti-clipping) ; le corps visible (Skin) se tourne
## vers la direction de déplacement. Structure inspirée du contrôleur MIT de GDQuest.
## ZQSD/WASD (touches physiques) + souris. Espace : saut. Shift : sprint. Échap : souris.

const WALK_SPEED := 5.0
const SPRINT_SPEED := 9.0
const ACCELERATION := 14.0
const JUMP_VELOCITY := 4.5
const MOUSE_SENSITIVITY := 0.003
const PITCH_MIN := -1.1
const PITCH_MAX := 0.4
const SKIN_ROTATION_SPEED := 10.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var skin: Node3D = $Skin


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# La caméra ne doit jamais entrer en collision avec le joueur lui-même.
	spring_arm.add_excluded_object(get_rid())


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		spring_arm.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		spring_arm.rotation.x = clampf(spring_arm.rotation.x, PITCH_MIN, PITCH_MAX)
	elif event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	# Déplacement relatif à la caméra (pas au corps) : style GTA.
	var direction := (camera_pivot.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y))
	direction.y = 0.0
	direction = direction.normalized() * input_dir.length()
	var speed := SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED

	var target := direction * speed
	velocity.x = move_toward(velocity.x, target.x, ACCELERATION * delta * speed)
	velocity.z = move_toward(velocity.z, target.z, ACCELERATION * delta * speed)

	if direction.length_squared() > 0.001:
		var target_yaw := atan2(direction.x, direction.z)
		skin.rotation.y = lerp_angle(skin.rotation.y, target_yaw, SKIN_ROTATION_SPEED * delta)

	move_and_slide()
