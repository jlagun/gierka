extends Node3D
## A short flash of fire and light at the muzzle.

## Seconds the flash stays.
@export var seconds: float = 0.05


func _ready() -> void:
	# A different angle every shot, so the flashes don't all look the same.
	rotate_object_local(Vector3.FORWARD, randf() * TAU)
	get_tree().create_timer(seconds).timeout.connect(queue_free)
