extends Node
## Autoload de debug : capture une image du jeu puis quitte.
## Inactif sans l'argument. Usage :
##   godot --path game -- --screenshot=C:/chemin/sortie.png [--shot-frames=45]

var _path := ""
var _wait := 45
var _frame := 0


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_path = arg.get_slice("=", 1)
		elif arg.begins_with("--shot-frames="):
			_wait = int(arg.get_slice("=", 1))
	if _path == "":
		set_process(false)


func _process(_delta: float) -> void:
	_frame += 1
	if _frame >= _wait:
		var img := get_viewport().get_texture().get_image()
		img.save_png(_path)
		print("[debug_screenshot] capture -> ", _path)
		get_tree().quit()
