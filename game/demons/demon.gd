class_name Demon
extends CharacterBody3D
## A demon. On the server it chases the nearest living player along the
## navigation mesh and attacks in melee. Clients only show it: spawning it on
## the server and replicating it to clients (M2.3) come later.
##
## The animations are states in the AnimationTree. "move" loops, "attack" and
## "hit" play once and then go back to "move", and "death" stays.

const MOVE: StringName = &"move"
const ATTACK: StringName = &"attack"
const HIT: StringName = &"hit"
const DEATH: StringName = &"death"
## The group every player joins. See Player.
const PLAYERS_GROUP: StringName = &"players"

## Health, speed, damage, attack range and cooldown.
@export var data: DemonData
## Seconds between two path updates. Updating every frame would cost too much
## with a wave of demons, and a player doesn't get far in a quarter second.
@export var repath_interval: float = 0.25
## How fast it turns to face where it's going, in degrees per second.
@export var turn_speed_degrees: float = 540.0

var _target: Node3D = null
var _time_to_repath: float = 0.0
var _time_since_attack: float = INF

@onready
var _playback: AnimationNodeStateMachinePlayback = $AnimationTree.get(&"parameters/playback")
@onready var _agent: NavigationAgent3D = $NavigationAgent3D
@onready var _health: Health = $Health
@onready var _voice: Node3D = $Head


func _enter_tree() -> void:
	# Health fills itself up to max_health in its own _ready, which runs before
	# this node's _ready. Setting it here, while the children are only entering
	# the tree, gives it the right maximum from the start.
	($Health as Health).max_health = data.health


func _ready() -> void:
	_health.health_changed.connect(_on_health_changed)
	_health.died.connect(_on_died)
	_start_growling()


## Plays one attack, then goes back to moving.
func play_attack() -> void:
	if _play_once(ATTACK):
		_play_sound(data.attack_sounds)


## Plays a flinch, then goes back to moving.
func play_hit() -> void:
	if _play_once(HIT):
		_play_sound(data.hit_sounds)


## Plays the death, and stays down.
func play_death() -> void:
	if _playback.get_current_node() == DEATH:
		return
	_playback.travel(DEATH)
	_play_sound(data.death_sounds)


## The animation state playing now: "move", "attack", "hit" or "death".
func get_animation_state() -> StringName:
	return _playback.get_current_node()


## The closest of the candidates that is still alive, or null if none is.
static func find_nearest_target(from: Vector3, candidates: Array[Node]) -> Node3D:
	var nearest: Node3D = null
	var nearest_distance := INF
	for candidate in candidates:
		var node := candidate as Node3D
		if node == null or not is_target_alive(node):
			continue
		var distance := from.distance_squared_to(node.global_position)
		if distance < nearest_distance:
			nearest = node
			nearest_distance = distance
	return nearest


## True if a target can still be hurt. Something without Health, like a player
## before players get health (M2.4), counts as alive.
static func is_target_alive(target: Node) -> bool:
	var health := target.get_node_or_null("Health") as Health
	return health == null or health.is_alive()


## True if a demon with this data may attack a target this far away now.
static func can_attack(demon_data: DemonData, distance: float, time_since_attack: float) -> bool:
	return distance <= demon_data.attack_range and time_since_attack >= demon_data.attack_cooldown


func _physics_process(delta: float) -> void:
	# The server is the authority for demons. A client only shows them.
	if not multiplayer.is_server() or not _health.is_alive():
		return
	_time_since_attack += delta
	_time_to_repath -= delta
	if _time_to_repath <= 0.0:
		_time_to_repath = repath_interval
		_target = find_nearest_target(global_position, get_tree().get_nodes_in_group(PLAYERS_GROUP))
		if _target != null:
			_agent.target_position = _target.global_position

	var walk := Vector3.ZERO
	if _target != null and is_instance_valid(_target) and is_target_alive(_target):
		var distance := _flat_distance_to(_target.global_position)
		if distance <= data.attack_range:
			# Close enough: stand and face the target instead of pushing into it.
			_turn_toward(_target.global_position - global_position, delta)
			if can_attack(data, distance, _time_since_attack):
				_attack(_target)
		elif not _agent.is_navigation_finished():
			var direction := _agent.get_next_path_position() - global_position
			direction.y = 0.0
			walk = direction.normalized() * data.speed
			_turn_toward(direction, delta)
	velocity.x = walk.x
	velocity.z = walk.z
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity += get_gravity() * delta
	move_and_slide()


func _attack(target: Node3D) -> void:
	_time_since_attack = 0.0
	play_attack()
	# The damage lands when the attack starts. Waiting for the blow in the
	# animation would let a player dodge, which the placeholder doesn't need yet.
	var health := target.get_node_or_null("Health") as Health
	if health != null:
		health.apply_damage(data.damage)


## Turns toward a direction on the ground, at most turn_speed_degrees a second.
func _turn_toward(direction: Vector3, delta: float) -> void:
	if Vector2(direction.x, direction.z).is_zero_approx():
		return
	# The model faces -Z, like a Godot camera.
	var wanted := atan2(-direction.x, -direction.z)
	rotation.y = rotate_toward(rotation.y, wanted, deg_to_rad(turn_speed_degrees) * delta)


## Distance on the ground, so a player jumping over a demon is still in reach.
func _flat_distance_to(point: Vector3) -> float:
	return Vector2(point.x - global_position.x, point.z - global_position.z).length()


func _on_health_changed(current: int, maximum: int) -> void:
	if current > 0 and current < maximum:
		play_hit()


func _on_died() -> void:
	play_death()
	# The body stays where it fell, but players and other demons walk through it.
	$CollisionShape3D.set_deferred(&"disabled", true)


## Plays a state that goes back to moving. False if the demon is dead, and
## the state didn't play.
func _play_once(state: StringName) -> bool:
	var current := _playback.get_current_node()
	# A dead demon stays down.
	if current == DEATH:
		return false
	# travel() doesn't restart the state it's already in, so a second attack
	# in a row starts over instead.
	if current == state:
		_playback.start(state)
	else:
		_playback.travel(state)
	return true


## Sounds come from the head, which is where a growl comes from.
func _play_sound(bank: SoundBank) -> void:
	if bank != null:
		bank.play_at(_voice)


## Growls now and then, after a random wait each time, until the demon dies.
func _start_growling() -> void:
	if data.growl_sounds == null or DisplayServer.get_name() == "headless":
		return
	var timer := Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_growl_timer_timeout.bind(timer))
	timer.start(randf_range(data.growl_interval_min, data.growl_interval_max))


func _on_growl_timer_timeout(timer: Timer) -> void:
	if get_animation_state() == DEATH:
		return
	_play_sound(data.growl_sounds)
	timer.start(randf_range(data.growl_interval_min, data.growl_interval_max))
