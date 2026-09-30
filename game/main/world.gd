extends Node3D
## One game session: the level and the players in it. Only the server spawns
## players; the PlayerSpawner then creates the same player on every client.

const PLAYER_SCENE: PackedScene = preload("res://player/player.tscn")

var _next_spawn_point: int = 0

@onready var _players: Node3D = $Players
@onready var _player_spawner: MultiplayerSpawner = $PlayerSpawner
@onready var _spawn_points: Node3D = $Level/SpawnPoints


func _ready() -> void:
	_player_spawner.spawn_function = _create_player
	Net.player_registered.connect(_on_player_registered)
	Net.player_unregistered.connect(_on_player_unregistered)


## Runs on every peer, with the same data, whenever the server spawns a player.
func _create_player(data: Variant) -> Node:
	var info: Dictionary = data
	var peer_id: int = info["peer_id"]
	var player: Player = PLAYER_SCENE.instantiate()
	player.name = str(peer_id)
	player.nickname = info["nickname"]
	player.position = info["position"]
	player.set_multiplayer_authority(peer_id)
	return player


func _on_player_registered(peer_id: int, nickname: String) -> void:
	var spawn_data := {
		"peer_id": peer_id,
		"nickname": nickname,
		"position": _pick_spawn_position(),
	}
	_player_spawner.spawn(spawn_data)


func _on_player_unregistered(peer_id: int) -> void:
	var player := _players.get_node_or_null(str(peer_id))
	if player != null:
		player.queue_free()


func _pick_spawn_position() -> Vector3:
	var points := _spawn_points.get_children()
	var point: Node3D = points[_next_spawn_point % points.size()]
	_next_spawn_point += 1
	return point.global_position
