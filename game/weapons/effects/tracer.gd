class_name Tracer
extends Node3D
## A thin streak from the muzzle to where a pellet went. It fades out quickly.

## Shorter than this, there's nothing worth drawing.
const MIN_LENGTH: float = 0.05

## Seconds the streak takes to fade out.
@export var fade_seconds: float = 0.1

@onready var _streak: MeshInstance3D = $Streak


## Lines the streak up with a shot, then fades it out. Call it once the tracer
## is in the tree, under a node that isn't a Node3D, so its transform is a
## world transform.
func stretch(from: Vector3, to: Vector3) -> void:
	var length := from.distance_to(to)
	# Written so that a NaN length also bails out.
	if not length > MIN_LENGTH:
		queue_free()
		return
	var direction := (to - from) / length
	# looking_at needs an up direction that isn't the shot's own direction.
	var up := Vector3.FORWARD if absf(direction.y) > 0.99 else Vector3.UP
	transform = Transform3D(Basis.looking_at(direction, up), from)
	# The streak is 1 m long along -Z, so scaling Z stretches it to the target.
	scale = Vector3(1.0, 1.0, length)
	var tween := create_tween()
	tween.tween_property(_streak, "transparency", 1.0, fade_seconds)
	tween.finished.connect(queue_free)
