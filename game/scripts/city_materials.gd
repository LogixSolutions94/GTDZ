extends Node3D
## Assigne les matériaux texturés aux lots de bâtiments du GLB généré depuis OSM
## (nœuds nommés "b_<cat><var>" par osm/osm_to_mesh.py) et l'asphalte aux routes.
## Si les textures ne sont pas présentes, on garde les couleurs unies du GLB.

const SHADER := preload("res://shaders/building_facade.gdshader")
const ROAD_SHADER := preload("res://shaders/road.gdshader")
const LANDMARK_SHADER := preload("res://shaders/landmark_photo.gdshader")
const TEX_DIR := "res://assets/textures/"

const ROOF_BY_CAT := {"res": "roof_flat.jpg", "com": "roof_flat.jpg", "pub": "roof_tiles.jpg"}

# Monuments : nœud dédié -> photo réelle (Wikimedia Commons, voir CREDITS.md)
# et taille de projection en mètres (largeur x hauteur de la façade couverte
# par une répétition de la photo).
const LANDMARK_TEXTURES := {
	"landmark_grande_poste": {
		"file": "landmarks/grande_poste.jpg",
		"size": Vector2(46.0, 23.7),
		"center": Vector2(410.8, 82.9),
		"radius": 26.0,
		"angle_offset": -0.91,
	},
}
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
	if n == "sidewalks":
		_apply_flat_material(mesh, "paving.jpg", 3.0, Color(0.95, 0.93, 0.9), Color(0.62, 0.6, 0.56))
		return
	if n.begins_with("landmark_"):
		_apply_landmark_material(mesh, n)
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


func _apply_landmark_material(mesh: MeshInstance3D, n: String) -> void:
	var info: Dictionary = LANDMARK_TEXTURES.get(n, {})
	var photo: Texture2D = _load_tex(info.get("file", "")) if not info.is_empty() else null
	var roof := _load_tex("roof_flat.jpg")
	if photo != null:
		# Photo réelle enroulée autour du bâtiment (projection cylindrique).
		var mat := ShaderMaterial.new()
		mat.shader = LANDMARK_SHADER
		mat.set_shader_parameter("photo", photo)
		mat.set_shader_parameter("photo_size_m", info.get("size", Vector2(40.0, 25.0)))
		mat.set_shader_parameter("center_xz", info.get("center", Vector2.ZERO))
		mat.set_shader_parameter("radius_m", info.get("radius", 25.0))
		mat.set_shader_parameter("angle_offset", info.get("angle_offset", 0.0))
		mat.set_shader_parameter("roof_tex", roof if roof != null else photo)
		mesh.material_override = mat
	elif _plaster != null:
		var mat := ShaderMaterial.new()
		mat.shader = SHADER
		mat.set_shader_parameter("facade_tex", _plaster)
		mat.set_shader_parameter("tint", Color(0.97, 0.94, 0.86))
		mat.set_shader_parameter("roof_tex", roof if roof != null else _plaster)
		mesh.material_override = mat


func _apply_road_material(mesh: MeshInstance3D) -> void:
	_apply_flat_material(mesh, "asphalt.jpg", 7.0, Color(0.75, 0.75, 0.78), Color(0.23, 0.23, 0.25))


## Matériau sol en projection monde XZ (routes, trottoirs) avec repli couleur unie.
func _apply_flat_material(mesh: MeshInstance3D, tex_file: String, size_m: float,
		tint: Color, fallback_color: Color) -> void:
	var tex := _load_tex(tex_file)
	if tex == null:
		var fallback := StandardMaterial3D.new()
		fallback.albedo_color = fallback_color
		fallback.roughness = 1.0
		mesh.material_override = fallback
		return
	var mat := ShaderMaterial.new()
	mat.shader = ROAD_SHADER
	mat.set_shader_parameter("tex", tex)
	mat.set_shader_parameter("size_m", size_m)
	mat.set_shader_parameter("tint", tint)
	mesh.material_override = mat


func _load_tex(fname: String) -> Texture2D:
	var path := TEX_DIR + fname
	if ResourceLoader.exists(path):
		return load(path)
	return null
