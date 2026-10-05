extends GutTest
## Unit tests for HitMarker: it flashes on a hit and fades out.

var _marker: HitMarker


func before_each() -> void:
	_marker = HitMarker.new()
	_marker.show_seconds = 0.2
	add_child_autofree(_marker)


func test_it_is_hidden_at_first() -> void:
	assert_false(_marker.is_showing())
	assert_eq(_marker.modulate.a, 0.0)


func test_a_hit_shows_it_fully() -> void:
	_marker.show_hit()
	assert_true(_marker.is_showing())
	assert_eq(_marker.modulate.a, 1.0)


func test_it_fades_out_after_show_seconds() -> void:
	_marker.show_hit()
	_marker._process(0.1)
	assert_almost_eq(_marker.modulate.a, 0.5, 0.001)
	_marker._process(0.1)
	assert_false(_marker.is_showing())
	assert_eq(_marker.modulate.a, 0.0)


func test_a_new_hit_starts_the_fade_over() -> void:
	_marker.show_hit()
	_marker._process(0.15)
	_marker.show_hit()
	assert_eq(_marker.modulate.a, 1.0)
