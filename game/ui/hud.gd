class_name Hud
extends CanvasLayer
## What a player sees on top of the game: a crosshair with a hit marker, the
## rounds left in the magazine, and the player's health. Only the player's own
## client has one.

var _weapon: Weapon = null
var _health: Health = null

@onready var _ammo: Label = $Ammo
@onready var _health_label: Label = $Health
@onready var _hit_marker: HitMarker = $HitMarker


func _ready() -> void:
	# Until there is a Health to follow, there is no number to show.
	_health_label.visible = false


## Shows this weapon's ammo, and flashes the hit marker when it hits, from now on.
func follow_weapon(weapon: Weapon) -> void:
	if _weapon != null:
		_weapon.ammo_changed.disconnect(_on_ammo_changed)
		_weapon.reload_started.disconnect(_on_reload_started)
		_weapon.fired.disconnect(_on_weapon_fired)
	_weapon = weapon
	weapon.ammo_changed.connect(_on_ammo_changed)
	weapon.reload_started.connect(_on_reload_started)
	weapon.fired.connect(_on_weapon_fired)
	if weapon.is_reloading():
		_on_reload_started()
	else:
		_on_ammo_changed(weapon.ammo)


## Shows these hit points from now on.
func follow_health(health: Health) -> void:
	if _health != null:
		_health.health_changed.disconnect(_on_health_changed)
	_health = health
	health.health_changed.connect(_on_health_changed)
	_health_label.visible = true
	_on_health_changed(health.current, health.max_health)


## True if any of a shot's traces hit something that can still be hurt. The
## marker trusts the shooter's own raycast, so it shows without waiting for the
## server. It can show for the rare hit the server then rejects.
static func is_hit(traces: Array[Weapon.Trace]) -> bool:
	for trace in traces:
		var target := HitClaims.find_damageable(trace.collider)
		if target == null:
			continue
		var health := target.get_node_or_null("Health") as Health
		if health != null and health.is_alive():
			return true
	return false


func _on_ammo_changed(ammo: int) -> void:
	_ammo.text = "%d / %d" % [ammo, _weapon.data.magazine_size]


func _on_reload_started() -> void:
	_ammo.text = tr("Reloading")


func _on_weapon_fired(traces: Array[Weapon.Trace]) -> void:
	if is_hit(traces):
		_hit_marker.show_hit()


func _on_health_changed(current: int, _maximum: int) -> void:
	_health_label.text = str(current)
