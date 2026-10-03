extends GutTest
## Unit tests for Health. Outside a network game a node counts as the server, so
## these run the server's side.

const HEALTH_SCENE: PackedScene = preload("res://rules/health.tscn")
const CLIENT_PEER_ID: int = 5

var _owner_node: Node
var _health: Health


func before_each() -> void:
	_owner_node = Node.new()
	add_child_autofree(_owner_node)
	_health = Health.new()
	_health.max_health = 50
	_owner_node.add_child(_health)


func test_starts_with_full_health() -> void:
	assert_eq(_health.current, 50)
	assert_true(_health.is_alive())


func test_the_owner_becomes_damageable() -> void:
	assert_true(_owner_node.is_in_group(Health.DAMAGEABLE_GROUP))


func test_damage_takes_hit_points_away() -> void:
	_health.apply_damage(20)
	assert_eq(_health.current, 30)


func test_health_stops_at_zero() -> void:
	_health.apply_damage(500)
	assert_eq(_health.current, 0)
	assert_false(_health.is_alive())


func test_negative_damage_does_not_heal() -> void:
	_health.apply_damage(20)
	_health.apply_damage(-100)
	assert_eq(_health.current, 30)


func test_died_is_emitted_once() -> void:
	watch_signals(_health)
	_health.apply_damage(50)
	_health.apply_damage(10)
	assert_signal_emit_count(_health, "died", 1)


func test_health_changed_reports_the_new_value() -> void:
	watch_signals(_health)
	_health.apply_damage(20)
	assert_signal_emitted_with_parameters(_health, "health_changed", [30, 50])


func test_the_server_stays_in_charge_under_a_node_a_client_owns() -> void:
	# Like a player: the spawn function hands the whole player to its client
	# before the player enters the tree.
	var player := Node.new()
	var health: Health = HEALTH_SCENE.instantiate()
	player.add_child(health)
	player.set_multiplayer_authority(CLIENT_PEER_ID)
	add_child_autofree(player)
	assert_eq(player.get_multiplayer_authority(), CLIENT_PEER_ID)
	assert_eq(health.get_multiplayer_authority(), MultiplayerPeer.TARGET_PEER_SERVER)
	var synchronizer := health.get_node("Synchronizer")
	assert_eq(synchronizer.get_multiplayer_authority(), MultiplayerPeer.TARGET_PEER_SERVER)
