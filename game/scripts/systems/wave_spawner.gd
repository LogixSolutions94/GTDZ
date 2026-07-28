extends Node3D
## Vagues d'ennemis infinies (mode survie/arcade) : 5, 7, 10, puis +2 par vague.
## Les ennemis apparaissent aux entrées de rues autour de la place (jamais sur
## le joueur), en mode chasse (ils convergent vers le joueur).

const ENEMY_SCENE := preload("res://scenes/enemies/enemy.tscn")

@export var spawn_points: Array[Vector3] = [
	Vector3(452, 0.5, 60),   # rue nord-est
	Vector3(455, 0.5, 100),  # rue est
	Vector3(378, 0.5, 58),   # rue nord-ouest
	Vector3(382, 0.5, 108),  # rue sud-ouest
	Vector3(408, 0.5, 42),   # rue nord
	Vector3(415, 0.5, 122),  # rue sud
]
@export var first_wave_delay := 4.0
@export var between_waves := 5.0
@export var spawn_spacing := 0.5

var _alive := 0


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	await get_tree().create_timer(first_wave_delay).timeout
	_start_wave(1)


func _enemies_for_wave(wave: int) -> int:
	match wave:
		1: return 5
		2: return 7
		3: return 10
		_: return 10 + 2 * (wave - 3)


func _start_wave(wave: int) -> void:
	if Game.state != Game.GameState.PLAYING:
		return
	Game.set_wave(wave)
	var count := _enemies_for_wave(wave)
	print("[vague] %d : %d ennemis" % [wave, count])
	for i in count:
		if Game.state != Game.GameState.PLAYING:
			return
		_spawn_enemy(spawn_points[randi() % spawn_points.size()])
		await get_tree().create_timer(spawn_spacing).timeout


func _spawn_enemy(point: Vector3) -> void:
	var enemy := ENEMY_SCENE.instantiate()
	enemy.lose_target_distance = 1000.0  # mode chasse : ne lâche jamais le joueur
	add_child(enemy)
	enemy.global_position = point + Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))
	enemy.get_node("Health").died.connect(_on_enemy_died)
	_alive += 1
	# Les ennemis de vague chassent d'emblée (pas de patrouille passive).
	enemy._set_detected(true)


func _on_enemy_died() -> void:
	_alive -= 1
	if _alive <= 0 and Game.state == Game.GameState.PLAYING:
		_wave_cleared()


func _wave_cleared() -> void:
	print("[vague] %d nettoyée" % Game.wave)
	await get_tree().create_timer(between_waves).timeout
	if Game.state == Game.GameState.PLAYING:
		_start_wave(Game.wave + 1)
