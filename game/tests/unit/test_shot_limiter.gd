extends GutTest
## Unit tests for ShotLimiter, the fire-rate check for hit claims.

const SHOTS_PER_SECOND: float = 5.0
const BURST: int = 3


func _new_limiter() -> ShotLimiter:
	return ShotLimiter.new(SHOTS_PER_SECOND, BURST, 0.0)


func test_a_burst_is_allowed() -> void:
	var limiter := _new_limiter()
	for _shot in BURST:
		assert_true(limiter.try_shot(0.0))


func test_shots_past_the_burst_are_refused() -> void:
	var limiter := _new_limiter()
	for _shot in BURST:
		limiter.try_shot(0.0)
	assert_false(limiter.try_shot(0.0))


func test_a_shot_at_the_weapons_pace_is_allowed() -> void:
	var limiter := _new_limiter()
	for _shot in BURST:
		limiter.try_shot(0.0)
	# One shot's worth of time has passed: 1 / 5 = 0.2 seconds.
	assert_true(limiter.try_shot(0.2))
	assert_false(limiter.try_shot(0.2))


func test_the_average_rate_cannot_beat_the_weapon() -> void:
	var limiter := _new_limiter()
	var allowed := 0
	# Ten seconds of claims, one every 50 ms: four times too fast.
	for step in 200:
		if limiter.try_shot(step * 0.05):
			allowed += 1
	# The weapon fires 50 shots in that time. The burst adds a few at the start.
	assert_between(allowed, 50, 50 + BURST)


func test_a_pause_does_not_save_up_more_than_the_burst() -> void:
	var limiter := _new_limiter()
	for _shot in BURST:
		limiter.try_shot(0.0)
	# A minute later, only a full bucket is there.
	for _shot in BURST:
		assert_true(limiter.try_shot(60.0))
	assert_false(limiter.try_shot(60.0))
