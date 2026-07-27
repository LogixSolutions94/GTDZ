extends StaticBody3D
## Cible d'entraînement : encaisse les dégâts via son composant Health,
## bascule au sol à la mort puis disparaît.

@onready var health: Health = $Health
@onready var mesh: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	health.changed.connect(_on_health_changed)
	health.died.connect(_on_died)


func _on_health_changed(current: float, max_health: float) -> void:
	# Rougit à mesure que la vie baisse.
	var mat := mesh.material_override as StandardMaterial3D
	if mat:
		mat.albedo_color = Color(0.8, 0.15 + 0.5 * current / max_health, 0.15)


func _on_died() -> void:
	var tween := create_tween()
	tween.tween_property(self, "rotation:x", -PI / 2.0, 0.45).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_interval(1.5)
	tween.tween_callback(queue_free)
