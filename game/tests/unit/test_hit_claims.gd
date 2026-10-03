extends GutTest
## Unit tests for the parts of HitClaims that don't need a network.

const MAX_RANGE: float = 50.0


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
