extends Control
## A small cross in the middle of the screen, where shots go. It's drawn rather
## than an image, so its size and colors are easy to tune.

## Length of each of the four arms, in pixels.
@export var arm_length: float = 8.0
## Space between the center and each arm, in pixels.
@export var gap: float = 4.0
## Line thickness, in pixels.
@export var thickness: float = 2.0
@export var color: Color = Color(1.0, 1.0, 1.0, 0.9)
## A dark edge, so the cross stays visible on bright walls.
@export var outline_color: Color = Color(0.0, 0.0, 0.0, 0.6)
## Width of the dark edge, in pixels.
@export var outline_width: float = 1.0


func _draw() -> void:
	# The edge first, a little longer and wider, then the cross on top.
	_draw_arms(outline_color, thickness + outline_width * 2.0, outline_width)
	_draw_arms(color, thickness, 0.0)


func _draw_arms(arm_color: Color, width: float, extra_length: float) -> void:
	for direction: Vector2 in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var from := direction * (gap - extra_length)
		var to := direction * (gap + arm_length + extra_length)
		draw_line(from, to, arm_color, width)
