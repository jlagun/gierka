extends Node3D
## Shows the demon's animations side by side. Open demon_preview.tscn in the
## editor and press F6 to run it. Each demon repeats one animation.

const DEMON_SCENE: PackedScene = preload("res://demons/demon.tscn")

## Seconds between two flinches of the "Hit" demon.
@export var hit_interval: float = 2.0
## Seconds the "Death" demon lies dead before a fresh one dies again.
@export var death_interval: float = 3.0

@onready var _attacking: Demon = $Attack
@onready var _flinching: Demon = $Hit
@onready var _dying: Demon = $Death


func _ready() -> void:
	# The attacking demon attacks as often as its data allows.
	_repeat(_attacking.data.attack_cooldown, _attacking.play_attack)
	_repeat(hit_interval, _flinching.play_hit)
	_repeat(death_interval, _die_again)
	_dying.play_death()


func _repeat(seconds: float, callback: Callable) -> void:
	var timer := Timer.new()
	timer.wait_time = seconds
	timer.autostart = true
	timer.timeout.connect(callback)
	add_child(timer)


func _die_again() -> void:
	# A dead demon stays down, so a fresh one takes its place.
	var fresh: Demon = DEMON_SCENE.instantiate()
	fresh.transform = _dying.transform
	_dying.free()
	fresh.name = "Death"
	add_child(fresh)
	_dying = fresh
	_dying.play_death()
