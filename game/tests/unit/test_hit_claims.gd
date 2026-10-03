extends GutTest
## Unit tests for the parts of HitClaims that don't need a network.

const MAX_RANGE: float = 50.0
const PLAYER_SCENE: PackedScene = preload("res://player/player.tscn")
const HEALTH_SCENE: PackedScene = preload("res://rules/health.tscn")
const SHOOTER_ID: int = 1

# Set by _make_world(), for the process_shot tests.
var _world: Node3D
var _claims: HitClaims
var _shooter: Player


func test_a_target_inside_the_range_is_in_range() -> void:
	assert_true(HitClaims.is_in_range(Vector3.ZERO, Vector3(0, 0, -30), MAX_RANGE))


func test_a_target_a_little_past_the_range_is_allowed_for_latency() -> void:
	var distance := MAX_RANGE + HitClaims.RANGE_SLACK_METERS - 0.1
	assert_true(HitClaims.is_in_range(Vector3.ZERO, Vector3(distance, 0, 0), MAX_RANGE))


func test_a_target_far_past_the_range_is_out_of_range() -> void:
	var distance := MAX_RANGE + HitClaims.RANGE_SLACK_METERS + 1.0
	assert_false(HitClaims.is_in_range(Vector3.ZERO, Vector3(distance, 0, 0), MAX_RANGE))


func test_find_damageable_finds_the_collider_itself() -> void:
	var body := StaticBody3D.new()
	add_child_autofree(body)
	body.add_to_group(Health.DAMAGEABLE_GROUP)
	assert_eq(HitClaims.find_damageable(body), body)


func test_find_damageable_finds_the_thing_a_collider_is_part_of() -> void:
	var target := Node3D.new()
	add_child_autofree(target)
	target.add_to_group(Health.DAMAGEABLE_GROUP)
	var part := StaticBody3D.new()
	target.add_child(part)
	assert_eq(HitClaims.find_damageable(part), target)


func test_find_damageable_returns_null_for_a_wall() -> void:
	var wall := StaticBody3D.new()
	add_child_autofree(wall)
	assert_null(HitClaims.find_damageable(wall))


func test_a_normal_claim_is_well_formed() -> void:
	assert_true(HitClaims.is_well_formed({"/root/World/Dummy": 1, "/root/World/Other": 2}))


func test_an_empty_claim_is_well_formed() -> void:
	assert_true(HitClaims.is_well_formed({}))


func test_a_claim_with_a_key_that_is_not_text_is_malformed() -> void:
	assert_false(HitClaims.is_well_formed({"/root/World/Dummy": 1, 42: 1}))


func test_a_claim_with_a_pellet_count_that_is_not_a_whole_number_is_malformed() -> void:
	assert_false(HitClaims.is_well_formed({"/root/World/Dummy": 1, "/root/World/Other": 1.5}))


# process_shot's checks, in a small world: a shooter (peer 1, which is what an
# offline test counts as), dummies with Health, and a wall. The pistol does 20
# damage with 1 pellet, and has a range of 50 m.


func test_a_good_claim_does_the_weapons_damage() -> void:
	_make_world()
	var dummy := _add_dummy(_world, Vector3(0, 0, -10))
	_claims.process_shot(SHOOTER_ID, {_path(dummy): 1})
	assert_eq(_health_of(dummy), 80)


func test_a_claim_for_something_outside_the_world_does_nothing() -> void:
	_make_world()
	var outsider := _add_dummy(self, Vector3(0, 0, -10))
	_claims.process_shot(SHOOTER_ID, {_path(outsider): 1})
	assert_eq(_health_of(outsider), 100)


func test_a_shooter_cannot_hit_themselves() -> void:
	_make_world()
	var health: Health = HEALTH_SCENE.instantiate()
	_shooter.add_child(health)
	_claims.process_shot(SHOOTER_ID, {_path(_shooter): 1})
	assert_eq(health.current, 100)


func test_a_claim_for_something_that_cant_be_hurt_does_nothing() -> void:
	_make_world()
	var wall := StaticBody3D.new()
	_world.add_child(wall)
	watch_signals(_claims)
	_claims.process_shot(SHOOTER_ID, {_path(wall): 1})
	assert_signal_not_emitted(_claims, "hit_applied")


func test_a_malformed_claim_does_nothing_at_all() -> void:
	_make_world()
	var dummy := _add_dummy(_world, Vector3(0, 0, -10))
	# The good hit comes first, so this also checks nothing is applied halfway.
	_claims.process_shot(SHOOTER_ID, {_path(dummy): 1, 42: 1})
	assert_eq(_health_of(dummy), 100)


func test_a_pellet_count_below_one_does_nothing() -> void:
	_make_world()
	var dummy := _add_dummy(_world, Vector3(0, 0, -10))
	_claims.process_shot(SHOOTER_ID, {_path(dummy): 0})
	_claims.process_shot(SHOOTER_ID, {_path(dummy): -5})
	assert_eq(_health_of(dummy), 100)


func test_a_claim_cannot_use_more_pellets_than_the_weapon_fires() -> void:
	_make_world()
	var first := _add_dummy(_world, Vector3(0, 0, -10))
	var second := _add_dummy(_world, Vector3(2, 0, -10))
	_claims.process_shot(SHOOTER_ID, {_path(first): 1000, _path(second): 1000})
	# The pistol fires 1 pellet, so only one of them takes 20 damage.
	assert_eq(_health_of(first) + _health_of(second), 180)


func test_a_target_out_of_range_is_not_hurt() -> void:
	_make_world()
	var far := _add_dummy(_world, Vector3(0, 0, -60))
	_claims.process_shot(SHOOTER_ID, {_path(far): 1})
	assert_eq(_health_of(far), 100)


func test_a_dead_target_is_not_hit_again() -> void:
	_make_world()
	var dummy := _add_dummy(_world, Vector3(0, 0, -10))
	(dummy.get_node("Health") as Health).apply_damage(100)
	watch_signals(_claims)
	_claims.process_shot(SHOOTER_ID, {_path(dummy): 1})
	assert_signal_not_emitted(_claims, "hit_applied")


func test_claims_faster_than_the_fire_rate_are_refused() -> void:
	_make_world()
	var dummy := _add_dummy(_world, Vector3(0, 0, -10))
	for _shot in HitClaims.SHOT_BURST + 2:
		_claims.process_shot(SHOOTER_ID, {_path(dummy): 1})
	# Only the burst gets through: 3 hits of 20.
	assert_eq(_health_of(dummy), 100 - HitClaims.SHOT_BURST * 20)


func test_a_claim_that_is_not_a_dictionary_is_ignored() -> void:
	_make_world()
	var dummy := _add_dummy(_world, Vector3(0, 0, -10))
	# What a modified client could send instead. The RPC would get the same
	# argument; calling it directly skips the network.
	_claims._claim_shot([_path(dummy), 1])
	assert_eq(_health_of(dummy), 100)


## Builds the world. Its parts are in _world, _claims and _shooter.
func _make_world() -> void:
	_world = Node3D.new()
	var players := Node3D.new()
	players.name = "Players"
	_world.add_child(players)
	_shooter = PLAYER_SCENE.instantiate()
	_shooter.name = str(SHOOTER_ID)
	players.add_child(_shooter)
	_claims = HitClaims.new()
	_claims.players = players
	_world.add_child(_claims)
	add_child_autofree(_world)


func _add_dummy(parent: Node, at: Vector3) -> Node3D:
	var dummy := StaticBody3D.new()
	dummy.position = at
	dummy.add_child(HEALTH_SCENE.instantiate())
	parent.add_child(dummy)
	# Dummies outside the world aren't freed with it.
	if parent == self:
		autofree(dummy)
	return dummy


func _path(node: Node) -> String:
	return str(node.get_path())


func _health_of(dummy: Node) -> int:
	return (dummy.get_node("Health") as Health).current
