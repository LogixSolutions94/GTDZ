extends CanvasLayer
## HUD : réticule, munitions, barre de vie. Se branche sur le joueur (groupe "player").

@onready var ammo_label: Label = $Ammo
@onready var health_bar: ProgressBar = $HealthBar


func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	player.ammo_changed.connect(_on_ammo_changed)
	player.health_changed.connect(_on_health_changed)
	# État initial (le joueur est prêt avant le HUD dans l'ordre de la scène).
	var weapon: HitscanWeapon = player.get_node_or_null("Weapon")
	if weapon:
		_on_ammo_changed(weapon.in_mag, weapon.reserve)
	var health: Health = player.get_node_or_null("Health")
	if health:
		_on_health_changed(health.current, health.max_health)


func _on_ammo_changed(in_mag: int, reserve: int) -> void:
	ammo_label.text = "%d / %d" % [in_mag, reserve]


func _on_health_changed(current: float, max_health: float) -> void:
	health_bar.max_value = max_health
	health_bar.value = current
