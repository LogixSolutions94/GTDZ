extends Area3D
## Chargeur à ramasser (lâché par les ennemis) : +30 en réserve, tourne sur lui-même.

@export var amount := 30


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	rotate_y(2.0 * delta)


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("add_ammo"):
		body.add_ammo(amount)
	queue_free()
