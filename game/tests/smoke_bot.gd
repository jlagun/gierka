extends Node
## Smoke-test bot, added to a client started with `--bot`. It walks its own
## player in a circle and watches the other players. It quits with exit code 0
## once it has seen another player, with a nickname, move; with 1 if that
## doesn't happen in time.

const TIMEOUT_SECONDS: float = 30.0
## Keep walking for a while after passing, so the other bot can see us move too.
const LINGER_SECONDS: float = 3.0
const MIN_DISTANCE: float = 1.0
const TURN_SPEED: float = 1.5  # radians per second

var _elapsed: float = 0.0
var _passed_at: float = -1.0
var _first_seen_at: Dictionary[StringName, Vector3] = {}


func _ready() -> void:
	# The same input action a player uses, so the real movement code runs.
	Input.action_press("move_forward")


func _physics_process(delta: float) -> void:
	_elapsed += delta
	for node in get_tree().get_nodes_in_group("players"):
		var player := node as Player
		if player.is_multiplayer_authority():
			player.rotate_y(TURN_SPEED * delta)
		else:
			_watch(player)

	if _passed_at >= 0.0 and _elapsed - _passed_at >= LINGER_SECONDS:
		print("SMOKE TEST PASSED")
		_finish(0)
	elif _elapsed >= TIMEOUT_SECONDS:
		printerr("SMOKE TEST FAILED: saw no other player move within %d seconds" % TIMEOUT_SECONDS)
		_finish(1)


func _watch(player: Player) -> void:
	if not _first_seen_at.has(player.name):
		_first_seen_at[player.name] = player.global_position
		print('Bot sees player "%s"' % player.nickname)
		return
	var moved := player.global_position.distance_to(_first_seen_at[player.name]) >= MIN_DISTANCE
	if _passed_at < 0.0 and moved and not player.nickname.is_empty():
		print('Bot saw player "%s" move' % player.nickname)
		_passed_at = _elapsed


func _finish(exit_code: int) -> void:
	set_physics_process(false)
	Input.action_release("move_forward")
	get_tree().quit(exit_code)
