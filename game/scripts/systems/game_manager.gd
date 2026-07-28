extends Node
## Autoload "Game" : état global de la partie (score, vague, game over, redémarrage).
## Décision de design : le redémarrage relance une partie COMPLÈTE (joueur, ennemis,
## vagues, score) via reload_current_scene — convention arcade/survie, zéro état résiduel.

enum GameState { PLAYING, GAME_OVER }

signal score_changed(score: int)
signal wave_changed(wave: int)
signal game_over_triggered(final_score: int, final_wave: int)

var state: GameState = GameState.PLAYING
var score := 0
var wave := 0
## Consommé par le joueur à son _ready après un redémarrage (invincibilité temporaire).
var pending_invincibility := false


func add_score(points: int) -> void:
	if state != GameState.PLAYING:
		return
	score += points
	score_changed.emit(score)


func set_wave(value: int) -> void:
	wave = value
	wave_changed.emit(wave)


func trigger_game_over() -> void:
	if state == GameState.GAME_OVER:
		return
	state = GameState.GAME_OVER
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_over_triggered.emit(score, wave)


func restart() -> void:
	state = GameState.PLAYING
	score = 0
	wave = 0
	pending_invincibility = true
	get_tree().paused = false
	get_tree().reload_current_scene()
