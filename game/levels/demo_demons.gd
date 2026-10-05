extends Node3D
## A few demons to try the demon AI (M2.2) before the server spawns demons
## itself (M2.3). Delete this node when M2.3 lands.
##
## Only the server runs demons, and nothing replicates these yet, so a client
## that joins drops its copies instead of showing demons that never move. Try
## them in a game you host.


func _ready() -> void:
	Net.server_joined.connect(queue_free)
	# Their Health would replicate to clients that no longer have them, and each
	# update would log an error there.
	for synchronizer in find_children("*", "MultiplayerSynchronizer", true, false):
		(synchronizer as MultiplayerSynchronizer).public_visibility = false
