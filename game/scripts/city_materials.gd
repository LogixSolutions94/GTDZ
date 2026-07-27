extends Node3D
## Assigne les matériaux texturés aux lots de bâtiments du GLB généré depuis OSM
## (nœuds nommés "b_<cat><var>" par osm/osm_to_mesh.py) et l'asphalte aux routes.
## Si les textures ne sont pas présentes, on garde les couleurs unies du GLB.

const SHADER := preload("res://shaders/building_facade.gdshader")
const TEX_DIR := "res://assets/textures/"

const ROOF_BY_CAT := {"res": "roof_flat.jpg", "com": "roof_flat.jpg", "pub": "roof_tiles.jpg"}
const TINTS := {
	"res": [Color(1.0, 1.0, 1.0), Color(0.96, 0.93, 0.87), Color(0.93, 0.89, 0.82)],
	"com": [Color(0.92, 0.92, 0.9), Color(0.88, 0.86, 0.82), Color(0.95, 0.93, 0.88)],
	"pub": [Color(0.97, 0.94, 0.86), Color(0.94, 0.9, 0.8), Color(0.96, 0.93, 0.85)],
}

var _facades: Array[Texture2D] = []
var _plaster: Texture2D = null


func _ready() -> void:
	for i in range(1, 9):
		var tex := _load_tex("facade_res_%02d.jpg" % i)
		if tex != null:
			_facades.append(tex)
	_plaster = _load_tex("plaster_01.jpg")
	# Recherche récursive : l'import GLB peut insérer des nœuds intermédiaires
	# entre la racine et les MeshInstance3D.
	var meshes := find_children("*", "MeshInstance3D", true, false)
	print("[city_materials] %d textures façades, %d MeshInstance3D : %s" % [
		_facades.size(), meshes.size(),
		", ".join(meshes.map(func(m): return String(m.name)))])
	for mesh in meshes:
		_apply_material(mesh)


func _apply_material(mesh: MeshInstance3D) -> void:
	var n := String(mesh.name)
	if n == "roads":
		_apply_road_material(mesh)
		return
	if not n.begins_with("b_") or n.length() < 6 or _facades.is_empty():
		return
	var cat := n.substr(2, 3)
	var variant := clampi(int(n.substr(5, 1)), 0, 2)
	if not TINTS.has(cat):
		return

	var facade: Texture2D
	match cat:
		"com":
			facade = _facades[(variant + 1) % _facades.size()]
		"pub":
			facade = _plaster if _plaster != null else _facades[variant % _facades.size()]
		_:
			facade = _facades[variant % _facades.size()]
	var roof := _load_tex(ROOF_BY_CAT.get(cat, "roof_flat.jpg"))

	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	mat.set_shader_parameter("facade_tex", facade)
	mat.set_shader_parameter("roof_tex", roof if roof != null else facade)
	mat.set_shader_parameter("tint", TINTS[cat][variant])
	mesh.material_override = mat


func _apply_road_material(mesh: MeshInstance3D) -> void:
	var mat := StandardMaterial3D.new()
	var tex := _load_tex("asphalt.jpg")
	if tex != null:
		mat.albedo_texture = tex
		mat.uv1_triplanar = true
		mat.uv1_world_triplanar = true
		mat.uv1_scale = Vector3(0.12, 0.12, 0.12)
	else:
		mat.albedo_color = Color(0.23, 0.23, 0.25)
	mat.roughness = 1.0
	mesh.material_override = mat


func _load_tex(fname: String) -> Texture2D:
	var path := TEX_DIR + fname
	if ResourceLoader.exists(path):
		return load(path)
	return null
