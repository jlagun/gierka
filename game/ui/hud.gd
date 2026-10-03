class_name Hud
extends CanvasLayer
## What a player sees on top of the game: a crosshair, and the rounds left in
## the magazine. Only the player's own client has one.

var _weapon: Weapon = null

@onready var _ammo: Label = $Ammo


## Shows this weapon's ammo from now on.
func follow_weapon(weapon: Weapon) -> void:
	if _weapon != null:
		_weapon.ammo_changed.disconnect(_on_ammo_changed)
		_weapon.reload_started.disconnect(_on_reload_started)
	_weapon = weapon
	weapon.ammo_changed.connect(_on_ammo_changed)
	weapon.reload_started.connect(_on_reload_started)
	if weapon.is_reloading():
		_on_reload_started()
	else:
		_on_ammo_changed(weapon.ammo)


func _on_ammo_changed(ammo: int) -> void:
	_ammo.text = "%d / %d" % [ammo, _weapon.data.magazine_size]


func _on_reload_started() -> void:
	_ammo.text = tr("Reloading")
