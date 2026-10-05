class_name SoundBank
extends Resource
## Several sounds for one event, like a demon's attack. Each time, one of them
## plays at random, with a slightly different pitch.
##
## Godot's AudioStreamRandomizer does the same, but it can't say which sound it
## picked. With log_choices on, every pick is printed, so during a playtest you
## can tell which sound you liked and remove the others from the list.
## The bank's resource_name says which event it is in that line.

## The sounds to pick from.
@export var streams: Array[AudioStream] = []
## How far the pitch varies, so repeats don't all sound the same.
@export_range(0.0, 0.5, 0.01) var pitch_variation: float = 0.08
## Print the file name of every sound picked.
@export var log_choices: bool = false


## Plays one of the sounds at a node, and follows it while it plays. Nothing
## plays on a headless server or bot, which has nobody to hear it.
func play_at(at: Node3D) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var stream := pick_stream()
	if stream == null:
		return
	if log_choices:
		print("Sound: %s -> %s" % [resource_name, stream.resource_path.get_file()])
	var sound := AudioStreamPlayer3D.new()
	sound.stream = stream
	sound.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	sound.finished.connect(sound.queue_free)
	at.add_child(sound)
	sound.play()


## One of the sounds, at random, or null if there are none.
func pick_stream() -> AudioStream:
	if streams.is_empty():
		return null
	return streams.pick_random()
