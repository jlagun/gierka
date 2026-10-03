extends StaticBody3D
## A target to shoot in the playtest. It shows its hit points above its head,
## and it gets them back a few seconds after it dies, so you can keep shooting.
##
## Throwaway: it only lives on the claude/playtest branch, until the real
## target dummies arrive with #15.

## Seconds a dead dummy waits before it gets its hit points back.
@export var revive_delay: float = 3.0

@onready var _health: Health = $Health
@onready var _hit_points: Label3D = $HitPoints
@onready var _revive_timer: Timer = $ReviveTimer


func _ready() -> void:
	_health.health_changed.connect(_on_health_changed)
	_health.died.connect(_on_died)
	_revive_timer.timeout.connect(_revive)
	# Health is ready before this node, so its first change was already sent.
	_on_health_changed(_health.current, _health.max_health)


func _on_health_changed(current: int, maximum: int) -> void:
	_hit_points.text = "%d / %d" % [current, maximum]


func _on_died() -> void:
	# The server owns the hit points. Clients only show them.
	if multiplayer.is_server():
		_revive_timer.start(revive_delay)


func _revive() -> void:
	# Health can't heal yet, so the server sets the hit points directly.
	_health.current = _health.max_health
