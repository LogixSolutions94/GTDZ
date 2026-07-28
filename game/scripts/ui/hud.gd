extends CanvasLayer
## HUD : réticule, munitions, barre de vie. Se branche sur le joueur (groupe "player").

@onready var ammo_label: Label = $Ammo
@onready var health_bar: ProgressBar = $HealthBar
@onready var game_over_panel: ColorRect = $GameOverPanel
@onready var final_score_label: Label = $GameOverPanel/Center/FinalScore
@onready var final_wave_label: Label = $GameOverPanel/Center/FinalWave
@onready var retry_button: Button = $GameOverPanel/Center/RetryButton
@onready var pause_panel: ColorRect = $PausePanel


@onready var score_label: Label = $Score
@onready var wave_label: Label = $Wave


func _ready() -> void:
	Game.game_over_triggered.connect(_on_game_over)
	Game.score_changed.connect(func(s: int): score_label.text = "Score : %d" % s)
	Game.wave_changed.connect(_on_wave_changed)
	score_label.text = "Score : %d" % Game.score
	retry_button.pressed.connect(Game.restart)
	pause_panel.get_node("Center/Reprendre").pressed.connect(func(): _set_paused(false))
	pause_panel.get_node("Center/Recommencer").pressed.connect(func():
		_set_paused(false)
		Game.restart())
	pause_panel.get_node("Center/MenuPrincipal").pressed.connect(func():
		_set_paused(false)
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn"))
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	player.ammo_changed.connect(_on_ammo_changed)
	player.health_changed.connect(_on_health_changed)
	# État initial (le joueur est prêt avant le HUD dans l'ordre de la scène).
	var weapon: HitscanWeapon = player.get_node_or_null("Weapon")
	if weapon:
		_on_ammo_changed(weapon.in_mag, weapon.reserve)
		weapon.hit_confirmed.connect(_flash_crosshair)
	var health: Health = player.get_node_or_null("Health")
	if health:
		_on_health_changed(health.current, health.max_health)


func _unhandled_input(event: InputEvent) -> void:
	if game_over_panel.visible and event.is_action_pressed("ui_accept"):
		Game.restart()
	elif event.is_action_pressed("ui_cancel") and not game_over_panel.visible:
		_set_paused(not get_tree().paused)


func _set_paused(value: bool) -> void:
	get_tree().paused = value
	pause_panel.visible = value
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if value else Input.MOUSE_MODE_CAPTURED


func _on_game_over(final_score: int, final_wave: int) -> void:
	final_score_label.text = "Score final : %d" % final_score
	final_wave_label.text = "Vague atteinte : %d" % final_wave
	game_over_panel.visible = true


func _on_wave_changed(wave: int) -> void:
	wave_label.text = "Vague %d" % wave if wave > 0 else ""


func _flash_crosshair() -> void:
	var crosshair: Label = $Crosshair
	crosshair.modulate = Color(1.0, 0.25, 0.2)
	var tween := create_tween()
	tween.tween_property(crosshair, "modulate", Color.WHITE, 0.18)


func _on_ammo_changed(in_mag: int, reserve: int) -> void:
	ammo_label.text = "%d / %d" % [in_mag, reserve]


func _on_health_changed(current: float, max_health: float) -> void:
	health_bar.max_value = max_health
	health_bar.value = current
