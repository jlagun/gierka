class_name Health
extends Node
## Hit points of something the server owns, like a target dummy or a demon.
##
## Add health.tscn under the thing that can be hurt. Its parent then joins the
## "damageable" group, which is how a hit claim finds it. Only the server
## changes the hit points. They replicate to every client through the
## Synchronizer node, so a player who joins later gets the current value too.

## Emitted on every peer whenever the hit points change.
signal health_changed(current: int, maximum: int)
## Emitted on every peer when the hit points drop to zero.
signal died

const DAMAGEABLE_GROUP: StringName = &"damageable"

@export var max_health: int = 100

## The hit points left. Change them only with apply_damage(), on the server.
var current: int = 0:
	set(value):
		var was_alive := current > 0
		current = clampi(value, 0, max_health)
		health_changed.emit(current, max_health)
		if was_alive and current == 0:
			died.emit()


func _ready() -> void:
	get_parent().add_to_group(DAMAGEABLE_GROUP)
	# A client waits for the server's value, which can already have arrived.
	if multiplayer.is_server():
		current = max_health


func is_alive() -> bool:
	return current > 0


## Takes hit points away. Only the server may do this.
func apply_damage(amount: int) -> void:
	if not multiplayer.is_server():
		push_error("Only the server can apply damage.")
		return
	current -= maxi(amount, 0)
