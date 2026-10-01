class_name HitClaims
extends Node
## Hits are claimed by the shooter and decided by the server.
##
## The shooter's client already did the raycast (Weapon). It sends one claim
## per shot: which damageable things its pellets hit, and how many pellets hit
## each. The server doesn't trust any of the numbers. It looks up the weapon the
## shooter really holds, and checks the fire rate, the range, and that the target
## is alive before it applies the damage.

## Emitted on the server for every claim it accepts.
signal hit_applied(shooter_id: int, target: Node3D, damage: int)

## How many shots in a row a shooter may claim at once. See ShotLimiter.
const SHOT_BURST: int = 3
## Extra reach for latency: the server sees the shooter and the target a little late.
const RANGE_SLACK_METERS: float = 3.0
## Where a shot starts, above the player's feet.
const EYE_HEIGHT: float = 1.6

## The node the players are spawned under.
@export var players: Node3D

## Peer id -> that shooter's fire-rate limit. Only used on the server.
var _limiters: Dictionary[int, ShotLimiter] = {}


func _ready() -> void:
	players.child_entered_tree.connect(_on_player_added)
	for player in players.get_children():
		_on_player_added(player)
	Net.player_unregistered.connect(_on_player_unregistered)


## True if a target is close enough to be hit by a weapon with this range.
static func is_in_range(from: Vector3, to: Vector3, max_range: float) -> bool:
	return from.distance_to(to) <= max_range + RANGE_SLACK_METERS


## Finds the damageable thing a ray hit: the collider itself, or what it is part of.
static func find_damageable(collider: Node) -> Node3D:
	var node := collider
	while node != null:
		if node.is_in_group(Health.DAMAGEABLE_GROUP):
			return node as Node3D
		node = node.get_parent()
	return null


## Runs on the server, for a claim from a client (or the host's own player).
func process_shot(shooter_id: int, hits: Dictionary) -> void:
	var shooter := players.get_node_or_null(str(shooter_id)) as Player
	if shooter == null:
		return
	var weapon_data := shooter.get_weapon().data
	if not _limiter_for(shooter_id, weapon_data).try_shot(_now_seconds()):
		print("Rejected a shot from peer %d: it came too soon" % shooter_id)
		return
	var eye := shooter.global_position + Vector3.UP * EYE_HEIGHT
	var pellets_left := weapon_data.pellets
	for key: Variant in hits:
		var pellet_hits: Variant = hits[key]
		# The claim comes from a client, so don't assume anything about its types.
		if typeof(key) != TYPE_STRING or typeof(pellet_hits) != TYPE_INT:
			return
		var target := _find_target(shooter, NodePath(key))
		if target == null:
			continue
		var health := target.get_node_or_null("Health") as Health
		if health == null or not health.is_alive():
			continue
		if not is_in_range(eye, target.global_position, weapon_data.max_range):
			print("Rejected a hit from peer %d: %s is out of range" % [shooter_id, target.name])
			continue
		# A shot can't hit with more pellets than the weapon fires.
		if pellets_left <= 0:
			return
		var count := clampi(pellet_hits, 1, pellets_left)
		pellets_left -= count
		var damage := count * weapon_data.damage
		health.apply_damage(damage)
		print("Hit: peer %d hit %s for %d damage" % [shooter_id, target.name, damage])
		hit_applied.emit(shooter_id, target, damage)


@rpc("any_peer", "call_remote", "reliable")
func _claim_shot(hits: Dictionary) -> void:
	if not multiplayer.is_server():
		return
	process_shot(multiplayer.get_remote_sender_id(), hits)


func _on_player_added(node: Node) -> void:
	var player := node as Player
	# Only the owner of a player shoots with it, and only the owner claims hits.
	if player != null and player.is_multiplayer_authority():
		player.get_weapon().fired.connect(_on_weapon_fired)


func _on_player_unregistered(peer_id: int) -> void:
	_limiters.erase(peer_id)


## Turns a shot's traces into a claim: target path -> number of pellets that hit it.
func _on_weapon_fired(traces: Array[Weapon.Trace]) -> void:
	var hits: Dictionary = {}
	for trace in traces:
		var target := find_damageable(trace.collider)
		if target != null:
			var path := str(target.get_path())
			hits[path] = int(hits.get(path, 0)) + 1
	if hits.is_empty():
		return
	if multiplayer.is_server():
		process_shot(multiplayer.get_unique_id(), hits)
	else:
		_claim_shot.rpc_id(1, hits)


## The damageable node at a path the client sent, or null if there isn't one that
## this shooter may hit.
func _find_target(shooter: Player, path: NodePath) -> Node3D:
	var node := get_node_or_null(path)
	# Only things in this game's world count, and nobody can hit themselves.
	if node == null or node == shooter or not get_parent().is_ancestor_of(node):
		return null
	if not node.is_in_group(Health.DAMAGEABLE_GROUP):
		return null
	return node as Node3D


func _limiter_for(peer_id: int, weapon_data: WeaponData) -> ShotLimiter:
	if not _limiters.has(peer_id):
		_limiters[peer_id] = ShotLimiter.new(weapon_data.fire_rate, SHOT_BURST, _now_seconds())
	return _limiters[peer_id]


func _now_seconds() -> float:
	return Time.get_ticks_msec() / 1000.0
