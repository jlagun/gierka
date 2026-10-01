extends GutTest
## Unit tests for the command-line options the game starts with.


func test_no_options_means_a_plain_client_with_the_menu() -> void:
	var options := LaunchOptions.parse(PackedStringArray())
	assert_false(options.server)
	assert_false(options.host)
	assert_false(options.bot)
	assert_eq(options.connect_address, "")
	assert_eq(options.port, Net.DEFAULT_PORT)


func test_server_flag() -> void:
	var options := LaunchOptions.parse(PackedStringArray(["--server"]))
	assert_true(options.server)


func test_host_and_bot_flags() -> void:
	var options := LaunchOptions.parse(PackedStringArray(["--host", "--bot"]))
	assert_true(options.host)
	assert_true(options.bot)


func test_options_with_values() -> void:
	var args := PackedStringArray(["--connect", "100.64.0.1", "--port", "7788", "--name", "Kuba"])
	var options := LaunchOptions.parse(args)
	assert_eq(options.connect_address, "100.64.0.1")
	assert_eq(options.port, 7788)
	assert_eq(options.nickname, "Kuba")


func test_options_can_come_in_any_order() -> void:
	var args := PackedStringArray(["--name", "Kuba", "--server", "--port", "7788"])
	var options := LaunchOptions.parse(args)
	assert_eq(options.nickname, "Kuba")
	assert_true(options.server)
	assert_eq(options.port, 7788)
