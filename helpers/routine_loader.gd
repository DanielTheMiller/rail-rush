class_name RoutineLoader

const routine_dir: String = "res://routines/"

static func load(name: String) -> Array[Action]:
	var file_path = routine_dir.path_join(name)
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content_as_text = file.get_as_text()
	var content_as_array = JSON.parse_string(content_as_text)
	return content_as_array

static func write(name: String, routine: Array[Action]):
	var serialized_content: String = JSON.stringify(routine)
	var file_path = routine_dir.path_join(name)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(serialized_content)	
