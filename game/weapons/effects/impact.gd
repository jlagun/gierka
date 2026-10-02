extends CPUParticles3D
## A burst of sparks where a pellet hit. ShotEffects points it along the
## surface's normal before adding it.


func _ready() -> void:
	finished.connect(queue_free)
	emitting = true
