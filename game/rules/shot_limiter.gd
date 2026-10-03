class_name ShotLimiter
extends RefCounted
## Keeps a shooter from claiming shots faster than their weapon can fire.
##
## It is a token bucket: every shot costs one token, and tokens come back at the
## weapon's fire rate. The bucket holds a few tokens, so a burst of claims that
## the network delivered together still passes, but the average rate can't
## beat the weapon's.

var _shots_per_second: float
var _capacity: float
var _tokens: float
var _last_seconds: float


## A new shooter starts with a full bucket.
func _init(shots_per_second: float, burst: int, now_seconds: float) -> void:
	_shots_per_second = shots_per_second
	_capacity = float(burst)
	_tokens = _capacity
	_last_seconds = now_seconds


## Returns true, and uses up a token, if a shot may be fired at this moment.
func try_shot(now_seconds: float) -> bool:
	var elapsed := maxf(now_seconds - _last_seconds, 0.0)
	_last_seconds = now_seconds
	_tokens = minf(_tokens + elapsed * _shots_per_second, _capacity)
	if _tokens < 1.0:
		return false
	_tokens -= 1.0
	return true
