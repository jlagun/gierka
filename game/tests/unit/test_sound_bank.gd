extends GutTest
## Unit tests for SoundBank, and for the banks the game uses.

const BASIC_DEMON: DemonData = preload("res://demons/basic_demon.tres")
const PLAYER_SCENE: PackedScene = preload("res://player/player.tscn")


func test_pick_stream_picks_one_of_the_sounds() -> void:
	var first := AudioStreamWAV.new()
	var second := AudioStreamWAV.new()
	var bank := SoundBank.new()
	bank.streams = [first, second]
	for i in 20:
		assert_has([first, second], bank.pick_stream())


func test_pick_stream_from_an_empty_bank_is_null() -> void:
	assert_null(SoundBank.new().pick_stream())


func test_the_basic_demon_has_every_sound() -> void:
	for bank: SoundBank in [
		BASIC_DEMON.growl_sounds,
		BASIC_DEMON.attack_sounds,
		BASIC_DEMON.hit_sounds,
		BASIC_DEMON.death_sounds,
	]:
		_assert_complete(bank)


func test_the_basic_demon_growls_after_a_sensible_wait() -> void:
	assert_gt(BASIC_DEMON.growl_interval_min, 0.0)
	assert_true(BASIC_DEMON.growl_interval_min <= BASIC_DEMON.growl_interval_max)


func test_the_player_has_hurt_sounds() -> void:
	var player: Player = PLAYER_SCENE.instantiate()
	_assert_complete(player.hurt_sounds)
	player.free()


## A bank that is set, has sounds, and loaded every one of them.
func _assert_complete(bank: SoundBank) -> void:
	assert_not_null(bank)
	if bank == null:
		return
	assert_false(bank.streams.is_empty(), "%s has no sounds" % bank.resource_name)
	for stream in bank.streams:
		assert_not_null(stream, "%s has a sound that didn't load" % bank.resource_name)
