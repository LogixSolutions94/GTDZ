extends StaticBody3D
## Voiture garée (décor) : teinte pseudo-aléatoire stable selon le nom du nœud.

const COLORS := [
	Color(0.85, 0.85, 0.88), Color(0.15, 0.15, 0.17), Color(0.6, 0.62, 0.65),
	Color(0.45, 0.1, 0.1), Color(0.75, 0.72, 0.62), Color(0.2, 0.3, 0.5),
]


func _ready() -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = COLORS[hash(String(name)) % COLORS.size()]
	mat.roughness = 0.35
	mat.metallic = 0.2
	$Body.material_override = mat
	$Cabin.material_override = mat
