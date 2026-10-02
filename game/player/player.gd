class_name Player
extends CharacterBody3D
## A player. The client that owns it moves it; everyone else sees its position
## and rotation through the Synchronizer node.

## Golden-ratio hue step, so players with neighboring peer ids get clearly
## different colors.
const HUE_STEP: float = 0.618034
const BODY_SATURATION: float = 0.55
const BODY_BRIGHTNESS: float = 0.9

@export var movement: MovementData
## Radians of rotation per pixel of mouse movement.
@export var mouse_sensitivity: float = 0.0025
@export var max_look_angle_degrees: float = 89.0

var nickname: String = ""

# Sprinting only starts and stops on the ground, so a jump keeps the speed it
# started with.
var _sprinting: bool = false
var _time_off_floor: float = INF
var _time_since_jump_press: float = INF

@onready var _head: Node3D = $Head
@onready var _camera: Camera3D = $Head/Camera3D
@onready var _weapon: Weapon = $Head/Weapon
@onready var _body: MeshInstance3D = $Body
@onready var _visor: MeshInstance3D = $Visor
@onready var _name_label: Label3D = $NameLabel


func _ready() -> void:
	assert(movement != null, "A Player needs its movement data set.")
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
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var gravity := get_gravity() * movement.gravity_scale
	if is_on_floor():
		_time_off_floor = 0.0
		# Forward only: backing away from demons at sprint speed while shooting
		# them would make them too easy.
		_sprinting = Input.is_action_pressed("sprint") and input.y < 0.0
	else:
		_time_off_floor += delta
		velocity += gravity * delta
	if Input.is_action_just_pressed("jump"):
		_time_since_jump_press = 0.0
	else:
		_time_since_jump_press += delta
	# A press just before landing, or just after running off a ledge, still jumps.
	if (
		_time_since_jump_press <= movement.jump_buffer_time
		and _time_off_floor <= movement.coyote_time
	):
		_jump(gravity.length(), delta)
	_move_horizontally(transform.basis * Vector3(input.x, 0.0, input.y), delta)
	move_and_slide()


func _jump(gravity: float, delta: float) -> void:
	# The first step up happens at full speed, before gravity slows it, which
	# would put the peak a few centimeters too high. Starting half a frame of
	# gravity slower puts it at jump_height.
	velocity.y = sqrt(2.0 * gravity * movement.jump_height) - gravity * delta / 2.0
	# Use both up, so a quick second press doesn't jump again in the air.
	_time_off_floor = INF
	_time_since_jump_press = INF


## Speeds up toward where the keys point, or slows down when none are held.
func _move_horizontally(direction: Vector3, delta: float) -> void:
	var rate: float
	if is_on_floor():
		rate = movement.acceleration if direction != Vector3.ZERO else movement.friction
	elif direction != Vector3.ZERO:
		rate = movement.air_acceleration
	else:
		# Nothing slows you down in the air, so a jump carries you its full length.
		return
	var target := direction * (movement.sprint_speed if _sprinting else movement.walk_speed)
	var horizontal := Vector3(velocity.x, 0.0, velocity.z).move_toward(target, rate * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z


func _capture_mouse() -> void:
	# A headless client, like the smoke-test bot, has no mouse to capture.
	if DisplayServer.get_name() != "headless":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _color_body() -> void:
	var hue := fmod(String(name).to_int() * HUE_STEP, 1.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color.from_hsv(hue, BODY_SATURATION, BODY_BRIGHTNESS)
	_body.material_override = material
