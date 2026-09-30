extends Node
## Boots the game. Depending on the command-line options it starts a dedicated
## server, a listen server with a local player, a client that joins right away,
## or the main menu.

const WORLD_SCENE: PackedScene = preload("res://main/world.tscn")
const MAIN_MENU_SCENE: PackedScene = preload("res://ui/main_menu.tscn")
const SMOKE_BOT_SCRIPT_PATH: String = "res://tests/smoke_bot.gd"

var _options: LaunchOptions
var _world: Node3D = null
var _menu: MainMenu = null


func _ready() -> void:
	_options = LaunchOptions.parse(OS.get_cmdline_user_args())
	Net.server_joined.connect(_on_server_joined)
	Net.connection_failed.connect(_on_connection_failed)
	Net.server_disconnected.connect(_on_server_disconnected)

	if _options.server:
		_start_server(_options.port, true, "")
	elif _options.host:
		_start_server(_options.port, false, _options.nickname)
	elif not _options.connect_address.is_empty():
		_join(_options.connect_address, _options.port, _options.nickname)
	else:
		_show_menu("")


## A dedicated server has no local player. A listen server's host plays too.
func _start_server(port: int, dedicated: bool, nickname: String) -> void:
	_close_menu()
	_open_world()
	var error := Net.start_server(port, dedicated)
	if error != OK:
		_abort(tr("Could not start a server on port %d.") % port)
		return
	print("Server listening on UDP port %d" % port)
	if not dedicated:
		Net.register_host_player(nickname)


func _join(address: String, port: int, nickname: String) -> void:
	# The world has to exist before the server starts sending us players.
	_open_world()
	var error := Net.join_server(address, port, nickname)
	if error != OK:
		_abort(tr("Could not connect to %s:%d.") % [address, port])
		return
	print("Connecting to %s:%d" % [address, port])
	if _menu != null:
		_menu.show_connecting(address)
	if _options.bot:
		var bot_script: GDScript = load(SMOKE_BOT_SCRIPT_PATH)
		add_child(bot_script.new())


func _open_world() -> void:
	_close_world()
	_world = WORLD_SCENE.instantiate()
	add_child(_world)


func _close_world() -> void:
	if _world != null:
		# Remove it right away, so a new world can take the same node path.
		remove_child(_world)
		_world.queue_free()
		_world = null


func _show_menu(message: String) -> void:
	_close_world()
	_close_menu()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_menu = MAIN_MENU_SCENE.instantiate()
	add_child(_menu)
	_menu.join_requested.connect(_join)
	_menu.host_requested.connect(_on_host_requested)
	_menu.show_message(message)


func _close_menu() -> void:
	if _menu != null:
		_menu.queue_free()
		_menu = null


## Bots and dedicated servers quit with an error code; players go back to the menu.
func _abort(message: String) -> void:
	Net.leave()
	if _options.server or _options.bot or DisplayServer.get_name() == "headless":
		printerr(message)
		get_tree().quit(1)
		return
	_show_menu(message)


func _on_host_requested(port: int, nickname: String) -> void:
	_start_server(port, false, nickname)


func _on_server_joined() -> void:
	print("Connected to the server")
	_close_menu()


func _on_connection_failed() -> void:
	_abort(tr("Could not connect to the server."))


func _on_server_disconnected() -> void:
	_abort(tr("Lost the connection to the server."))
