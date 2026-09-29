class_name LaunchOptions
extends RefCounted
## Command-line options, given after `--`. For example:
##     godot --path game -- --connect 127.0.0.1 --name Kuba

## Run a dedicated server, without a local player.
var server: bool = false
## Run a server with a local player (a "listen server"), for quick tests.
var host: bool = false
## Join this server right away instead of showing the main menu.
var connect_address: String = ""
var port: int = Net.DEFAULT_PORT
var nickname: String = ""
## Walk around automatically and check that other players move (smoke test).
var bot: bool = false


static func parse(args: PackedStringArray) -> LaunchOptions:
	var options := LaunchOptions.new()
	var index := 0
	while index < args.size():
		var arg := args[index]
		if arg in ["--connect", "--port", "--name"]:
			index += 1
			if index < args.size():
				options._set_value(arg, args[index])
			else:
				push_error("Missing a value after %s" % arg)
		elif arg == "--server":
			options.server = true
		elif arg == "--host":
			options.host = true
		elif arg == "--bot":
			options.bot = true
		else:
			push_warning("Unknown command-line option: %s" % arg)
		index += 1
	return options


func _set_value(option: String, value: String) -> void:
	match option:
		"--connect":
			connect_address = value
		"--name":
			nickname = value
		"--port":
			if value.is_valid_int():
				port = value.to_int()
			else:
				push_error("Not a port number: %s" % value)
