extends Node
## Autoload de debug : capture d'écran + hooks de test. Inactif sans arguments.
## Usage :
##   godot --path game -- --screenshot=C:/sortie.png [--shot-frames=45]
##                        [--kill-player=N] [--add-score=N]

var _path := ""
var _wait := 45
var _frame := 0
var _kill_player_at := -1
var _restart_at := -1
var _kill_enemies_at := -1
var _add_score := 0
var _cam_yaw_deg := 0.0
var _autoplay := false
var _draw_weapon := 0
var _teleport := Vector3.INF


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_path = arg.get_slice("=", 1)
		elif arg.begins_with("--shot-frames="):
			_wait = int(arg.get_slice("=", 1))
		elif arg.begins_with("--kill-player="):
			_kill_player_at = int(arg.get_slice("=", 1))
		elif arg.begins_with("--restart-at="):
			_restart_at = int(arg.get_slice("=", 1))
		elif arg.begins_with("--kill-enemies="):
			_kill_enemies_at = int(arg.get_slice("=", 1))
		elif arg.begins_with("--add-score="):
			_add_score = int(arg.get_slice("=", 1))
		elif arg.begins_with("--cam-yaw="):
			_cam_yaw_deg = float(arg.get_slice("=", 1))
		elif arg == "--play":
			_autoplay = true
		elif arg.begins_with("--draw-weapon="):
			_draw_weapon = int(arg.get_slice("=", 1))
		elif arg.begins_with("--teleport="):
			var parts := arg.get_slice("=", 1).split(",")
			if parts.size() == 3:
				_teleport = Vector3(float(parts[0]), float(parts[1]), float(parts[2]))
	if _path == "" and _kill_player_at < 0 and _add_score == 0 and _restart_at < 0 \
			and _kill_enemies_at < 0:
		set_process(false)


func _process(_delta: float) -> void:
	_frame += 1
	if _frame == 2 and _autoplay:
		Game.state = Game.GameState.PLAYING
		get_tree().change_scene_to_file("res://scenes/city_test.tscn")
	if _frame == 6 and _teleport != Vector3.INF:
		var tp_player := get_tree().get_first_node_in_group("player")
		if tp_player:
			tp_player.global_position = _teleport
	if _frame == 8 and _draw_weapon > 0:
		var armed_player := get_tree().get_first_node_in_group("player")
		if armed_player:
			armed_player._select_weapon(armed_player.weapon_ak if _draw_weapon == 1 else armed_player.weapon_smg)
	if _frame == 5 and _cam_yaw_deg != 0.0:
		var player := get_tree().get_first_node_in_group("player")
		if player:
			player.camera_pivot.rotate_y(deg_to_rad(_cam_yaw_deg))
	if _frame == 10 and _add_score > 0:
		Game.add_score(_add_score)
		print("[debug] score de test injecté : ", _add_score)
	if _frame == _kill_player_at:
		var player := get_tree().get_first_node_in_group("player")
		if player:
			player.get_node("Health").take_damage(9999.0)
			print("[debug] joueur tué (test game over)")
	if _frame == _restart_at:
		print("[debug] redémarrage (test respawn)")
		Game.restart()
	if _frame == _kill_enemies_at:
		var enemies := get_tree().get_nodes_in_group("enemies")
		print("[debug] élimination de %d ennemis (test vagues)" % enemies.size())
		for enemy in enemies:
			enemy.get_node("Health").take_damage(9999.0)
	if _path != "" and _frame >= _wait:
		var img := get_viewport().get_texture().get_image()
		img.save_png(_path)
		print("[debug_screenshot] capture -> ", _path)
		get_tree().quit()
