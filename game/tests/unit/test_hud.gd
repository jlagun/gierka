extends GutTest
## Unit tests for Hud: when the hit marker counts a shot as a hit, and how it
## shows health. Outside a network game a node counts as the server.

const HUD_SCENE: PackedScene = preload("res://ui/hud.tscn")

var _hud: Hud


func before_each() -> void:
	_hud = HUD_SCENE.instantiate()
	add_child_autofree(_hud)


func test_a_trace_into_a_damageable_target_is_a_hit() -> void:
	var traces: Array[Weapon.Trace] = [_trace_into(_target(10))]
	assert_true(Hud.is_hit(traces))


func test_a_trace_into_a_part_of_a_damageable_target_is_a_hit() -> void:
	var part := StaticBody3D.new()
	_target(10).add_child(part)
	var traces: Array[Weapon.Trace] = [_trace_into(part)]
	assert_true(Hud.is_hit(traces))


func test_a_trace_into_a_wall_is_not_a_hit() -> void:
	var wall := StaticBody3D.new()
	add_child_autofree(wall)
	var traces: Array[Weapon.Trace] = [_trace_into(wall)]
	assert_false(Hud.is_hit(traces))


func test_a_trace_into_nothing_is_not_a_hit() -> void:
	var traces: Array[Weapon.Trace] = [Weapon.Trace.new()]
	assert_false(Hud.is_hit(traces))


func test_a_trace_into_a_dead_target_is_not_a_hit() -> void:
	var target := _target(10)
	(target.get_node("Health") as Health).apply_damage(10)
	var traces: Array[Weapon.Trace] = [_trace_into(target)]
	assert_false(Hud.is_hit(traces))


func test_health_is_hidden_until_there_is_health_to_follow() -> void:
	var label: Label = _hud.get_node("Health")
	assert_false(label.visible)


func test_health_shows_the_current_hit_points() -> void:
	var health := _target(100).get_node("Health") as Health
	_hud.follow_health(health)
	health.apply_damage(30)
	var label: Label = _hud.get_node("Health")
	assert_true(label.visible)
	assert_eq(label.text, "70")


## Something damageable, with this many hit points.
func _target(max_health: int) -> Node3D:
	var target := Node3D.new()
	var health := Health.new()
	health.name = "Health"
	health.max_health = max_health
	target.add_child(health)
	add_child_autofree(target)
	return target


func _trace_into(collider: Node3D) -> Weapon.Trace:
	var trace := Weapon.Trace.new()
	trace.collider = collider
	return trace
