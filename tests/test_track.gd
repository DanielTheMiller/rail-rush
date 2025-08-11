extends GutTest

var piece_scene := preload("res://tiles/track_piece.tscn")

func test_track_can_spin():
	const ROTATION_BEFORE = 0;
	var rail_instance: Track = piece_scene.instantiate()
	rail_instance.target_rotation = ROTATION_BEFORE
	self.add_child(rail_instance)
	await rail_instance.spin(true)
	await get_tree().create_timer(0.5).timeout
	assert_eq(rail_instance.target_rotation, ROTATION_BEFORE + 90, "Target rotation hasn't been iterated")
	assert_eq(rail_instance.rotation_degrees, ROTATION_BEFORE + 90,  "Rotation hasn't been iterated")
