extends GutTest
## Unit tests for the parts of the Net autoload that don't need a connection.

## The script, not the autoload: clean_nickname is a static function.
const NetScript: GDScript = preload("res://net/net.gd")
const PEER_ID: int = 42


func test_clean_nickname_keeps_a_normal_name() -> void:
	assert_eq(NetScript.clean_nickname("Kuba", PEER_ID), "Kuba")


func test_clean_nickname_trims_spaces_around_the_name() -> void:
	assert_eq(NetScript.clean_nickname("  Kuba  ", PEER_ID), "Kuba")


func test_clean_nickname_cuts_a_long_name() -> void:
	var long_name := "A".repeat(NetScript.MAX_NICKNAME_LENGTH + 10)
	var expected := "A".repeat(NetScript.MAX_NICKNAME_LENGTH)
	assert_eq(NetScript.clean_nickname(long_name, PEER_ID), expected)


func test_clean_nickname_removes_control_characters() -> void:
	assert_eq(NetScript.clean_nickname("Ku\nb\ta\u0007", PEER_ID), "Kuba")


func test_clean_nickname_falls_back_to_the_peer_id_when_empty() -> void:
	assert_eq(NetScript.clean_nickname("", PEER_ID), "Player 42")


func test_clean_nickname_falls_back_when_only_spaces_and_control_characters() -> void:
	assert_eq(NetScript.clean_nickname(" \t\n ", PEER_ID), "Player 42")


func test_clean_nickname_does_not_leave_trailing_space_after_cutting() -> void:
	var kept := "A".repeat(NetScript.MAX_NICKNAME_LENGTH - 1)
	assert_eq(NetScript.clean_nickname(kept + " B", PEER_ID), kept)
