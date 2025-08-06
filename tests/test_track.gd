extends GutTest

var piece_scene := preload("res://tiles/track_piece.tscn")

func test_track_can_spin():
	var rail_instance: Track = piece_scene.instantiate()
	rail_instance.target_rotation = (randi() % 4) * 90
	self.add_child(rail_instance)
	rail_instance.spin(true)
