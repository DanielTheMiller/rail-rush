extends TextureRect

func _gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed):
		var parent = self.get_parent();
		parent.spin(event.button_index == MOUSE_BUTTON_LEFT)
	
