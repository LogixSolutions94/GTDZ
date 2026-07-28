extends CharacterBody3D
## Contrôleur 3e personne type GTA (phase 1).
## Caméra orbitale (pivot + SpringArm anti-clipping) ; le corps visible (Skin) se tourne
## vers la direction de déplacement. Structure inspirée du contrôleur MIT de GDQuest.
## ZQSD/WASD (touches physiques) + souris. Espace : saut. Shift : sprint. Échap : souris.

signal ammo_changed(in_mag: int, reserve: int)
signal health_changed(current: float, max_health: float)
signal weapon_changed(weapon_name: String, in_mag: int, reserve: int)
signal aim_changed(aiming: bool)

const WALK_SPEED := 5.0
const SPRINT_SPEED := 9.0
const ACCELERATION := 14.0
const JUMP_VELOCITY := 4.5
const MOUSE_SENSITIVITY := 0.003
const PITCH_MIN := -1.1
const PITCH_MAX := 0.4
const SKIN_ROTATION_SPEED := 10.0
# Visée épaule : la caméra se rapproche et zoome.
const NORMAL_SPRING := 4.0
const AIM_SPRING := 1.7
const NORMAL_FOV := 75.0
const AIM_FOV := 55.0
const AIM_LERP := 10.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var skin: Node3D = $Skin
@onready var weapon_ak: HitscanWeapon = $WeaponAK
@onready var weapon_smg: HitscanWeapon = $WeaponSMG
@onready var health: Health = $Health

## Arme en main (null = rangée : pas de viseur, pas de tir).
var current_weapon: HitscanWeapon = null
var _aiming := false

var _anim: AnimationPlayer = null
var _anim_idle := &""
var _anim_walk := &""
var _anim_run := &""
var _anim_jump := &""


func _ready() -> void:
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# La caméra ne doit jamais entrer en collision avec le joueur lui-même.
	spring_arm.add_excluded_object(get_rid())
	for w in [weapon_ak, weapon_smg]:
		var weapon := w as HitscanWeapon
		weapon.ammo_changed.connect(func(m: int, r: int):
			if weapon == current_weapon:
				ammo_changed.emit(m, r))
		# Recul vertical propre à chaque arme (feel).
		weapon.fired.connect(func():
			spring_arm.rotation.x = clampf(spring_arm.rotation.x + weapon.recoil, PITCH_MIN, PITCH_MAX))
	health.changed.connect(func(c: float, mx: float): health_changed.emit(c, mx))
	health.died.connect(_on_died)
	_setup_animations()
	if Game.pending_invincibility:
		Game.pending_invincibility = false
		_start_invincibility(3.0)


func _start_invincibility(duration: float) -> void:
	print("[player] invincibilité post-respawn %.1f s" % duration)
	health.invulnerable = true
	var blinks := int(duration / 0.3)
	var tween := create_tween()
	for i in blinks:
		tween.tween_callback(func(): skin.visible = false)
		tween.tween_interval(0.15)
		tween.tween_callback(func(): skin.visible = true)
		tween.tween_interval(0.15)
	tween.tween_callback(func():
		health.invulnerable = false
		skin.visible = true)


func _on_died() -> void:
	# Gel complet des contrôles ; l'écran de game over prend la main (HUD).
	set_physics_process(false)
	set_process_unhandled_input(false)
	Game.trigger_game_over()


func _setup_animations() -> void:
	_anim = skin.find_child("AnimationPlayer", true, false)
	if _anim == null:
		return
	# Les noms d'animations importés peuvent être préfixés (ex. "Armature|Run") :
	# on cherche par suffixe pour rester robuste.
	_anim_idle = _find_animation("idle")
	_anim_walk = _find_animation("walk")
	_anim_run = _find_animation("run")
	_anim_jump = _find_animation("jump")
	if _anim_idle != &"":
		_anim.play(_anim_idle)


func _find_animation(name_part: String) -> StringName:
	for anim_name in _anim.get_animation_list():
		var lower := String(anim_name).to_lower()
		if lower == name_part or lower.ends_with(name_part) or lower.begins_with(name_part):
			return anim_name
	return &""


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		spring_arm.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		spring_arm.rotation.x = clampf(spring_arm.rotation.x, PITCH_MIN, PITCH_MAX)
	# Échap est géré par le menu pause (HUD).


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		var jump_sound := get_node_or_null("JumpSound")
		if jump_sound:
			jump_sound.play()

	# Sélection d'arme : 1 = AK-47, 2 = SMG, H = ranger.
	if Input.is_action_just_pressed("weapon_1"):
		_select_weapon(weapon_ak)
	elif Input.is_action_just_pressed("weapon_2"):
		_select_weapon(weapon_smg)
	elif Input.is_action_just_pressed("holster"):
		_select_weapon(null)

	# Tir / visée / rechargement : uniquement arme en main et souris capturée.
	var armed := current_weapon != null
	if armed and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if Input.is_action_pressed("shoot"):
			current_weapon.try_fire(camera, _aiming)
		if Input.is_action_just_pressed("reload"):
			current_weapon.reload()
	var aiming := armed and Input.is_action_pressed("aim") \
		and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if aiming != _aiming:
		_aiming = aiming
		aim_changed.emit(_aiming)
	spring_arm.spring_length = lerpf(spring_arm.spring_length, AIM_SPRING if _aiming else NORMAL_SPRING, AIM_LERP * delta)
	camera.fov = lerpf(camera.fov, AIM_FOV if _aiming else NORMAL_FOV, AIM_LERP * delta)

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
	_update_animation()


func _select_weapon(weapon: HitscanWeapon) -> void:
	if weapon == current_weapon:
		return
	current_weapon = weapon
	# Modèle 3D en main : montré uniquement pour l'arme active.
	var mount := skin.get_node_or_null("WeaponMount")
	if mount:
		for model in mount.get_children():
			model.visible = current_weapon != null and model.name == current_weapon.weapon_name.replace("-", "")
	if current_weapon:
		weapon_changed.emit(current_weapon.weapon_name, current_weapon.in_mag, current_weapon.reserve)
	else:
		weapon_changed.emit("", 0, 0)


## Munitions ramassées : dans l'arme en main, sinon partagées entre les deux.
func add_ammo(amount: int) -> void:
	if current_weapon:
		current_weapon.add_reserve(amount)
	else:
		weapon_ak.add_reserve(amount / 2)
		weapon_smg.add_reserve(amount / 2)


func _update_animation() -> void:
	if _anim == null:
		return
	var target := _anim_idle
	if not is_on_floor():
		target = _anim_jump
	else:
		var h_speed := Vector2(velocity.x, velocity.z).length()
		if h_speed > WALK_SPEED + 0.5:
			target = _anim_run
		elif h_speed > 0.5:
			target = _anim_walk
	if target != &"" and _anim.current_animation != String(target):
		_anim.play(target, 0.2)
