class_name MovementData
extends Resource
## How a player moves: top speeds, how quickly speed changes, and the jump.
## The numbers are in player/movement.tres. They have no defaults here, because
## Godot doesn't save a value that equals its default, and the numbers would
## then slip out of the .tres and back into code.

## Top speed on foot, in meters per second.
@export_range(0.5, 20.0, 0.1, "or_greater") var walk_speed: float
## Top speed while sprinting. Sprinting only works while moving forward.
@export_range(0.5, 20.0, 0.1, "or_greater") var sprint_speed: float
## How quickly you speed up and change direction on the ground, in m/s².
## Reaching full speed takes speed / acceleration seconds.
@export_range(1.0, 200.0, 1.0, "or_greater") var acceleration: float
## How quickly you stop on the ground after letting go of the keys, in m/s².
## Stopping takes speed / friction seconds.
@export_range(1.0, 200.0, 1.0, "or_greater") var friction: float
## How much you can steer in the air, in m/s². Letting go of the keys in the
## air doesn't slow you down.
@export_range(0.0, 100.0, 0.5, "or_greater") var air_acceleration: float
## How high a jump lifts your feet, in meters.
@export_range(0.1, 5.0, 0.05, "or_greater") var jump_height: float
## Multiplies the project's gravity, which is Earth's. Higher makes jumps and
## falls quicker without changing the jump height. At 1, jumps feel floaty.
@export_range(0.1, 5.0, 0.05, "or_greater") var gravity_scale: float
## Seconds after running off a ledge during which a jump still works.
@export_range(0.0, 0.5, 0.01) var coyote_time: float
## Seconds a jump press is remembered while in the air, so pressing it just
## before landing still jumps.
@export_range(0.0, 0.5, 0.01) var jump_buffer_time: float
