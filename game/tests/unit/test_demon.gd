extends GutTest
## Unit tests for Demon: how it picks a target and when it may attack. Outside a
## network game a node counts as the server.

const DEMON_SCENE: PackedScene = preload("res://demons/demon.tscn")

var _data: DemonData


func before_each() -> void:
	_data = DemonData.new()
	_data.health = 40
	_data.attack_range = 1.5
	_data.attack_cooldown = 1.0


func test_find_nearest_target_picks_the_closest() -> void:
	var far := _target_at(Vector3(10, 0, 0))
	var near := _target_at(Vector3(0, 0, 3))
	var candidates: Array[Node] = [far, near]
	assert_eq(Demon.find_nearest_target(Vector3.ZERO, candidates), near)


func test_find_nearest_target_skips_the_dead() -> void:
	var dead := _target_at(Vector3(1, 0, 0))
	var health := Health.new()
	health.name = "Health"
	health.max_health = 10
	dead.add_child(health)
	health.apply_damage(10)
	var alive := _target_at(Vector3(5, 0, 0))
	var candidates: Array[Node] = [dead, alive]
	assert_eq(Demon.find_nearest_target(Vector3.ZERO, candidates), alive)


func test_find_nearest_target_without_candidates_is_null() -> void:
	var candidates: Array[Node] = []
	assert_null(Demon.find_nearest_target(Vector3.ZERO, candidates))


func test_a_target_without_health_counts_as_alive() -> void:
	assert_true(Demon.is_target_alive(_target_at(Vector3.ZERO)))


func test_can_attack_in_range_after_the_cooldown() -> void:
	assert_true(Demon.can_attack(_data, 1.5, 1.0))


func test_can_attack_is_false_out_of_range() -> void:
	assert_false(Demon.can_attack(_data, 1.6, 5.0))


func test_can_attack_is_false_during_the_cooldown() -> void:
	assert_false(Demon.can_attack(_data, 1.0, 0.9))


func test_a_demon_starts_with_the_health_from_its_data() -> void:
	var demon: Demon = DEMON_SCENE.instantiate()
	demon.data = _data
	add_child_autofree(demon)
	var health: Health = demon.get_node("Health")
	assert_eq(health.max_health, 40)
	assert_eq(health.current, 40)


func test_a_dead_demon_stops_blocking() -> void:
	var demon: Demon = DEMON_SCENE.instantiate()
	add_child_autofree(demon)
	var health: Health = demon.get_node("Health")
	health.apply_damage(health.max_health)
	await wait_physics_frames(1)
	var shape: CollisionShape3D = demon.get_node("CollisionShape3D")
	assert_true(shape.disabled)


func _target_at(position: Vector3) -> Node3D:
	var target := Node3D.new()
	target.position = position
	add_child_autofree(target)
	return target
