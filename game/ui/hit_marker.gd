class_name HitMarker
extends Control
## A small X around the crosshair that flashes when a shot hits something. It's
## drawn like the crosshair, so the two match and are tuned the same way.

## Length of each of the four arms, in pixels.
@export var arm_length: float = 7.0
## Space between the center and each arm, in pixels. Wider than the crosshair's,
## so the X sits around the cross instead of on top of it.
@export var gap: float = 9.0
## Line thickness, in pixels.
@export var thickness: float = 2.0
@export var color: Color = Color(1.0, 1.0, 1.0, 1.0)
## A dark edge, so the X stays visible on bright walls.
@export var outline_color: Color = Color(0.0, 0.0, 0.0, 0.6)
## Width of the dark edge, in pixels.
@export var outline_width: float = 1.0
## Seconds from a hit until the X has faded out.
@export var show_seconds: float = 0.25

var _time_left: float = 0.0


func _ready() -> void:
	modulate.a = 0.0
	set_process(false)


## Flashes the X. A new hit starts the fade over.
func show_hit() -> void:
	_time_left = show_seconds
	modulate.a = 1.0
	set_process(true)


func is_showing() -> bool:
	return _time_left > 0.0


func _process(delta: float) -> void:
	_time_left = maxf(_time_left - delta, 0.0)
	modulate.a = _time_left / show_seconds
	if _time_left == 0.0:
		set_process(false)


func _draw() -> void:
	# The edge first, a little longer and wider, then the X on top.
	_draw_arms(outline_color, thickness + outline_width * 2.0, outline_width)
	_draw_arms(color, thickness, 0.0)


func _draw_arms(arm_color: Color, width: float, extra_length: float) -> void:
	for direction: Vector2 in [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]:
		var unit := direction.normalized()
		var from := unit * (gap - extra_length)
		var to := unit * (gap + arm_length + extra_length)
		draw_line(from, to, arm_color, width)
