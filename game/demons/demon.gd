class_name Demon
extends CharacterBody3D
## A demon. So far it only shows its model and plays its animations. The AI
## that moves it (M2.2) and spawning it on the server (M2.3) come later.
##
## The animations are states in the AnimationTree. "move" loops, "attack" and
## "hit" play once and then go back to "move", and "death" stays.

const MOVE: StringName = &"move"
const ATTACK: StringName = &"attack"
const HIT: StringName = &"hit"
const DEATH: StringName = &"death"

## Health, speed, damage, attack range and cooldown.
@export var data: DemonData

@onready
var _playback: AnimationNodeStateMachinePlayback = $AnimationTree.get(&"parameters/playback")


## Plays one attack, then goes back to moving.
func play_attack() -> void:
	_play_once(ATTACK)


## Plays a flinch, then goes back to moving.
func play_hit() -> void:
	_play_once(HIT)


## Plays the death, and stays down.
func play_death() -> void:
	_playback.travel(DEATH)


## The animation state playing now: "move", "attack", "hit" or "death".
func get_animation_state() -> StringName:
	return _playback.get_current_node()


func _play_once(state: StringName) -> void:
	var current := _playback.get_current_node()
	# A dead demon stays down.
	if current == DEATH:
		return
	# travel() doesn't restart the state it's already in, so a second attack
	# in a row starts over instead.
	if current == state:
		_playback.start(state)
	else:
		_playback.travel(state)
