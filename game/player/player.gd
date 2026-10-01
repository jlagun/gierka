class_name Player
extends CharacterBody3D
## A player. The client that owns it moves it; everyone else sees its position
## and rotation through the Synchronizer node.

## Golden-ratio hue step, so players with neighboring peer ids get clearly
## different colors.
const HUE_STEP: float = 0.618034
const BODY_SATURATION: float = 0.55
const BODY_BRIGHTNESS: float = 0.9

@export var move_speed: float = 5.0
@export var jump_velocity: float = 4.5
## Radians of rotation per pixel of mouse movement.
@export var mouse_sensitivity: float = 0.0025
@export var max_look_angle_degrees: float = 89.0

var nickname: String = ""

@onready var _head: Node3D = $Head
@onready var _camera: Camera3D = $Head/Camera3D
@onready var _weapon: Weapon = $Head/Weapon
@onready var _body: MeshInstance3D = $Body
@onready var _visor: MeshInstance3D = $Visor
@onready var _name_label: Label3D = $NameLabel


func _ready() -> void:
	add_to_group("players")
	_name_label.text = nickname
	_color_body()
	var is_local := is_multiplayer_authority()
	set_physics_process(is_local)
	set_process_unhandled_input(is_local)
	if is_local:
		_camera.current = true
		# Our own body would block our camera, but its shadow is nice to see.
		_body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		_visor.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		_name_label.visible = false
		_capture_mouse()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		# While the mouse is free, a click only takes it back; it doesn't shoot.
		if event is InputEventMouseButton and event.is_pressed():
			_capture_mouse()
	elif event.is_action_pressed("fire"):
		_weapon.pull_trigger()
	elif event.is_action_pressed("reload"):
		_weapon.reload()
	elif event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event
		rotate_y(-motion.relative.x * mouse_sensitivity)
		var max_angle := deg_to_rad(max_look_angle_degrees)
		_head.rotation.x = clampf(
			_head.rotation.x - motion.relative.y * mouse_sensitivity, -max_angle, max_angle
		)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := transform.basis * Vector3(input.x, 0.0, input.y)
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	move_and_slide()


func _capture_mouse() -> void:
	# A headless client, like the smoke-test bot, has no mouse to capture.
	if DisplayServer.get_name() != "headless":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _color_body() -> void:
	var hue := fmod(String(name).to_int() * HUE_STEP, 1.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color.from_hsv(hue, BODY_SATURATION, BODY_BRIGHTNESS)
	_body.material_override = material
