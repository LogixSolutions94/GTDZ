class_name Health
extends Node
## Composant de vie générique : à ajouter comme enfant nommé "Health" de
## n'importe quel corps (joueur, ennemi, objet destructible).

signal changed(current: float, max_health: float)
signal died

@export var max_health := 100.0
## Ignore tous les dégâts tant que vrai (invincibilité temporaire post-respawn).
var invulnerable := false

var current: float


func _ready() -> void:
	current = max_health


func take_damage(amount: float) -> void:
	if current <= 0.0 or invulnerable:
		return
	current = maxf(0.0, current - amount)
	changed.emit(current, max_health)
	if current == 0.0:
		died.emit()


func heal(amount: float) -> void:
	if current <= 0.0:
		return
	current = minf(max_health, current + amount)
	changed.emit(current, max_health)
