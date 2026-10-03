class_name ShotEffects
extends Node
## Shows every shot to every player: a flash at the muzzle, a tracer to where
## each pellet went, sparks where it hit, and the weapon's sound.
##
## The shooter's client shows its own shot at once. Then it sends the pellets'
## end points to everyone else, who show the shot on their copy of the shooter.
## It's only for show: hits and damage are the server's business.
##
## Tracers and sparks are added under this node. It isn't a Node3D, so their
## positions are world positions.

## How far the shot sound's pitch varies, so repeated shots don't all sound
## the same. 0.05 is up to 5% higher or lower.
@export_range(0.0, 0.5, 0.01) var pitch_variation: float = 0.05
## The node the players are spawned under.
@export var players: Node


func _ready() -> void:
	players.child_entered_tree.connect(_on_player_added)


func _on_player_added(node: Node) -> void:
	var player := node as Player
	# Only our own player's shots start here. Everyone else's arrive by RPC.
	if player != null and player.is_multiplayer_authority():
		var weapon: Weapon = player.get_node("Head/Weapon")
		weapon.fired.connect(_on_own_shot.bind(weapon))


func _on_own_shot(traces: Array[Weapon.Trace], weapon: Weapon) -> void:
	var ends := PackedVector3Array()
	var normals := PackedVector3Array()
	for trace in traces:
		ends.append(trace.to)
		normals.append(trace.normal)
	_show(weapon, ends, normals)
	_show_shot.rpc(ends, normals)


## Runs for everyone but the shooter. The shooter is whoever sent it, so
## nobody can show shots for someone else.
@rpc("any_peer", "call_remote", "unreliable")
func _show_shot(ends: PackedVector3Array, normals: PackedVector3Array) -> void:
	var shooter := players.get_node_or_null(str(multiplayer.get_remote_sender_id()))
	# Someone who has only just joined may not have the shooter's player yet.
	if shooter == null:
		return
	var weapon: Weapon = shooter.get_node("Head/Weapon")
	# It's only for show, but a broken message mustn't flood anyone's screen.
	if ends.size() != normals.size() or ends.size() > weapon.data.pellets:
		return
	for i in ends.size():
		if not (ends[i].is_finite() and normals[i].is_finite()):
			return
	_show(weapon, ends, normals)


func _show(weapon: Weapon, ends: PackedVector3Array, normals: PackedVector3Array) -> void:
	# A headless server or bot has nobody to show it to.
	if DisplayServer.get_name() == "headless":
		return
	var data := weapon.data
	var muzzle := weapon.get_muzzle()
	if data.muzzle_flash != null:
		muzzle.add_child(data.muzzle_flash.instantiate())
	if data.shot_sound != null:
		_play_sound(data.shot_sound, muzzle)
	for i in ends.size():
		if data.tracer != null:
			var tracer: Tracer = data.tracer.instantiate()
			add_child(tracer)
			tracer.stretch(muzzle.global_position, ends[i])
		# A pellet that hit nothing has no normal, and makes no sparks.
		if data.impact != null and normals[i] != Vector3.ZERO:
			var impact: CPUParticles3D = data.impact.instantiate()
			impact.position = ends[i]
			impact.direction = normals[i]
			add_child(impact)


func _play_sound(stream: AudioStream, at: Node3D) -> void:
	# One player per shot, so a new shot doesn't cut off the last one's tail.
	var sound := AudioStreamPlayer3D.new()
	sound.stream = stream
	sound.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	sound.finished.connect(sound.queue_free)
	at.add_child(sound)
	sound.play()
