extends Control
## Menu principal.


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Center/Jouer.pressed.connect(_on_play)
	$Center/Quitter.pressed.connect(func(): get_tree().quit())
	$Center/Jouer.grab_focus()


func _on_play() -> void:
	Game.state = Game.GameState.PLAYING
	Game.score = 0
	Game.wave = 0
	get_tree().change_scene_to_file("res://scenes/city_test.tscn")
