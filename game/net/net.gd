extends Node
## Networking: starts a server or joins one, and keeps the registry of players.
##
## The server owns the registry (peer id -> nickname). A client sends its
## nickname once, right after it connects, and the server registers it.

## Emitted on the server when a player has connected and sent a nickname.
signal player_registered(peer_id: int, nickname: String)
## Emitted on the server when a registered player disconnects.
signal player_unregistered(peer_id: int)
## Emitted on a client once it is connected to the server.
signal server_joined
## Emitted on a client when it can't reach the server.
signal connection_failed
## Emitted on a client when the connection to the server drops.
signal server_disconnected

const DEFAULT_PORT: int = 7777
const MAX_PLAYERS: int = 8
const MAX_NICKNAME_LENGTH: int = 16
## ENet alone can keep trying for half a minute; a mistyped address should fail sooner.
const CONNECT_TIMEOUT_SECONDS: float = 10.0
## Code point ranges dropped from nicknames: control characters, and invisible
## characters that change how the text around them shows. For example, U+202E
## would make a name read backwards.
const HIDDEN_CHARACTER_RANGES: Array[Vector2i] = [
	Vector2i(0x0000, 0x001F),  # control characters
	Vector2i(0x007F, 0x009F),  # delete and more control characters
	Vector2i(0x061C, 0x061C),  # Arabic letter mark
	Vector2i(0x200B, 0x200F),  # zero-width characters, direction marks
	Vector2i(0x2028, 0x202E),  # line and paragraph separators, direction overrides
	Vector2i(0x2060, 0x206F),  # word joiner, direction isolates, other invisible characters
	Vector2i(0xFEFF, 0xFEFF),  # zero-width no-break space
]

## Peer id -> nickname. Only filled in on the server.
var players: Dictionary[int, String] = {}

var _nickname_to_send: String = ""


func _ready() -> void:
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


## Starts listening for players on the given UDP port. On a listen server the
## host plays too, which leaves room for one client fewer.
func start_server(port: int, dedicated: bool) -> Error:
	var max_clients := MAX_PLAYERS if dedicated else MAX_PLAYERS - 1
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(port, max_clients)
	if error != OK:
		return error
	multiplayer.multiplayer_peer = peer
	return OK


## Registers the host's own player on a listen server. The host is peer 1.
func register_host_player(nickname: String) -> void:
	_register(multiplayer.get_unique_id(), nickname)


## Connects to a server. The nickname is sent once the connection is up.
func join_server(address: String, port: int, nickname: String) -> Error:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, port)
	if error != OK:
		return error
	multiplayer.multiplayer_peer = peer
	_nickname_to_send = nickname
	get_tree().create_timer(CONNECT_TIMEOUT_SECONDS).timeout.connect(_on_connect_timeout.bind(peer))
	return OK


## Closes the connection, or stops the server.
func leave() -> void:
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()


## Returns a nickname that is safe to show above a player's head.
static func clean_nickname(nickname: String, peer_id: int) -> String:
	var cleaned := ""
	for character in nickname:
		if not _is_hidden_character(character.unicode_at(0)):
			cleaned += character
	cleaned = cleaned.strip_edges().left(MAX_NICKNAME_LENGTH).strip_edges()
	if cleaned.is_empty():
		cleaned = "Player %d" % peer_id
	return cleaned


static func _is_hidden_character(code: int) -> bool:
	for hidden_range in HIDDEN_CHARACTER_RANGES:
		if code >= hidden_range.x and code <= hidden_range.y:
			return true
	return false


func _register(peer_id: int, nickname: String) -> void:
	var cleaned := clean_nickname(nickname, peer_id)
	players[peer_id] = cleaned
	print("Player joined: %s (peer %d)" % [cleaned, peer_id])
	player_registered.emit(peer_id, cleaned)


@rpc("any_peer", "call_remote", "reliable")
func _request_registration(nickname: String) -> void:
	if not multiplayer.is_server():
		return
	var peer_id := multiplayer.get_remote_sender_id()
	if players.has(peer_id):
		return
	_register(peer_id, nickname)


func _on_connected_to_server() -> void:
	_request_registration.rpc_id(1, _nickname_to_send)
	server_joined.emit()


func _on_peer_disconnected(peer_id: int) -> void:
	if multiplayer.is_server() and players.erase(peer_id):
		print("Player left: peer %d" % peer_id)
		player_unregistered.emit(peer_id)


func _on_connect_timeout(peer: MultiplayerPeer) -> void:
	# Only give up if this is still the same attempt and it isn't connected yet.
	var still_connecting := peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING
	if multiplayer.multiplayer_peer == peer and still_connecting:
		leave()
		connection_failed.emit()


func _on_connection_failed() -> void:
	connection_failed.emit()


func _on_server_disconnected() -> void:
	server_disconnected.emit()
