class_name Weapon
extends Node3D
## A hitscan weapon: each shot is one instant ray per pellet, from the aim
## point. It keeps track of the magazine and reloads.
##
## Hits do no damage here. By the networking rules in CLAUDE.md, the shooter
## only reports them, and the server checks them and applies the damage.

## Emitted after each shot, with one trace per pellet.
signal fired(traces: Array[Trace])
## Emitted when the number of rounds in the magazine changes.
signal ammo_changed(ammo: int)
## Emitted when a reload starts. It takes data.reload_time seconds.
signal reload_started

const HIT_MARKER_RADIUS: float = 0.05
const HIT_MARKER_COLOR: Color = Color(1.0, 0.85, 0.1)

@export var data: WeaponData
## Shots start here and fly along its -Z axis. Usually the camera.
@export var aim: Node3D
## The body holding the weapon, so that its own shots pass through it.
@export var holder: CollisionObject3D

@export_group("Feel")
## How far the model tips up with each shot, in degrees.
@export var kick_degrees: float = 6.0
## Seconds the model takes to settle after a kick.
@export var kick_recovery_seconds: float = 0.15
## How far the model drops while reloading, in meters.
@export var reload_drop: float = 0.2

@export_group("Debug")
## Leaves a small marker wherever a shot hits, to check aim and spread. Only
## the player holding the weapon sees them.
@export var show_hits: bool = false
## Seconds a hit marker stays.
@export var hit_marker_seconds: float = 2.0

## Rounds left in the magazine.
var ammo: int = 0

var _cooldown_left: float = 0.0
var _reload_left: float = 0.0
var _trigger_pulled: bool = false
var _rest_position: Vector3 = Vector3.ZERO
var _kick_tween: Tween = null
var _reload_tween: Tween = null
var _hit_marker_mesh: SphereMesh = null
var _muzzle: Node3D = null

@onready var _view_model: Node3D = $ViewModel


func _ready() -> void:
	assert(data != null and aim != null, "A Weapon needs its data and aim set.")
	ammo = data.magazine_size
	_rest_position = _view_model.position
	_muzzle = _view_model
	if data.model != null:
		var model := data.model.instantiate()
		_view_model.add_child(model)
		var muzzle := model.get_node_or_null(^"Muzzle") as Node3D
		if muzzle != null:
			_muzzle = muzzle
	# Only the player holding the weapon shoots with it.
	set_physics_process(is_multiplayer_authority())


func _physics_process(delta: float) -> void:
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)
	if _reload_left > 0.0:
		_reload_left -= delta
		if _reload_left <= 0.0:
			_finish_reload()
	# Shots wait for the physics frame, the safe time to cast rays.
	if _trigger_pulled:
		_trigger_pulled = false
		_fire()


## Fires on the next physics frame, unless the weapon is reloading or between
## shots. With an empty magazine, it reloads instead.
func pull_trigger() -> void:
	_trigger_pulled = true


## Starts a reload, unless the magazine is full or a reload is already running.
func reload() -> void:
	if is_reloading() or ammo >= data.magazine_size:
		return
	_reload_left = data.reload_time
	reload_started.emit()
	_play_reload()


func is_reloading() -> bool:
	return _reload_left > 0.0


## Where shot effects start: the model's "Muzzle" marker, or the view model if
## the model has none.
func get_muzzle() -> Node3D:
	return _muzzle


func _fire() -> void:
	if is_reloading() or _cooldown_left > 0.0:
		return
	if ammo <= 0:
		# Defensive: the last shot already starts a reload, so this only runs if
		# something else empties the magazine.
		reload()
		return
	ammo -= 1
	_cooldown_left = 1.0 / data.fire_rate
	var traces: Array[Trace] = []
	for _pellet in data.pellets:
		traces.append(_trace_pellet())
	ammo_changed.emit(ammo)
	fired.emit(traces)
	_play_kick()
	if show_hits:
		_mark_hits(traces)
	if ammo == 0:
		reload()


func _finish_reload() -> void:
	_reload_left = 0.0
	ammo = data.magazine_size
	ammo_changed.emit(ammo)


func _trace_pellet() -> Trace:
	var trace := Trace.new()
	trace.from = aim.global_position
	var forward := (-aim.global_basis.z).normalized()
	var direction := _spread(forward, aim.global_basis.y.normalized())
	trace.to = trace.from + direction * data.max_range
	var query := PhysicsRayQueryParameters3D.create(trace.from, trace.to)
	if holder != null:
		var exclude: Array[RID] = [holder.get_rid()]
		query.exclude = exclude
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		trace.to = hit["position"]
		trace.normal = hit["normal"]
		trace.collider = hit["collider"] as Node3D
	return trace


## Tips the forward direction away by a random angle, up to the spread.
func _spread(forward: Vector3, up: Vector3) -> Vector3:
	if data.spread <= 0.0:
		return forward
	# The square root spreads pellets evenly over the cone, instead of bunching
	# them in the middle.
	var tilt := deg_to_rad(data.spread) * sqrt(randf())
	return forward.rotated(up, tilt).rotated(forward, randf() * TAU)


func _play_kick() -> void:
	if _kick_tween != null:
		_kick_tween.kill()
	_view_model.rotation.x = deg_to_rad(kick_degrees)
	_kick_tween = create_tween()
	_kick_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_kick_tween.tween_property(_view_model, "rotation:x", 0.0, kick_recovery_seconds)


func _play_reload() -> void:
	if _reload_tween != null:
		_reload_tween.kill()
	var half_time := data.reload_time / 2.0
	_reload_tween = create_tween()
	_reload_tween.tween_property(
		_view_model, "position", _rest_position + Vector3.DOWN * reload_drop, half_time
	)
	_reload_tween.tween_property(_view_model, "position", _rest_position, half_time)


func _mark_hits(traces: Array[Trace]) -> void:
	if _hit_marker_mesh == null:
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = HIT_MARKER_COLOR
		_hit_marker_mesh = SphereMesh.new()
		_hit_marker_mesh.radius = HIT_MARKER_RADIUS
		_hit_marker_mesh.height = HIT_MARKER_RADIUS * 2.0
		_hit_marker_mesh.material = material
	for trace in traces:
		if trace.collider == null:
			continue
		var marker := MeshInstance3D.new()
		marker.mesh = _hit_marker_mesh
		# On what was hit, so the marker moves with it.
		trace.collider.add_child(marker)
		marker.global_position = trace.to
		get_tree().create_timer(hit_marker_seconds).timeout.connect(marker.queue_free)


## One pellet's path: from the aim point to what it hit, or to the end of its
## range.
class Trace:
	var from: Vector3 = Vector3.ZERO
	var to: Vector3 = Vector3.ZERO
	## What the pellet hit, or null if it hit nothing.
	var collider: Node3D = null
	## The surface normal where it hit. Zero on a miss.
	var normal: Vector3 = Vector3.ZERO
