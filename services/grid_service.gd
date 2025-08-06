class_name GridService

var piece_scene := preload("res://tiles/track_piece.tscn")

var rail_instances: Dictionary = {} # TODO: Perhaps rename to GRID
var allowed_rail_types: Array[Constants.RailType] = [Constants.RailType.STRAIGHT, Constants.RailType.CURVE]
var main

func _init(main_param, auto_populate: bool=true):
	self.main = main_param
	if auto_populate:
		create_game_grid()

func create_game_grid() -> void:
	for x in range(0, Constants.GRID_WIDTH):
		for y in range(0, Constants.GRID_HEIGHT):
			var rail_type: Constants.RailType = allowed_rail_types[randi() % len(allowed_rail_types)]
			spawn_rail(Vector2i(x, y), rail_type)
		# Create the rails for de/spawning on
		for y in [-1, Constants.GRID_HEIGHT]:
			spawn_rail(Vector2i(x, y), Constants.RailType.OUT_OF_BOUNDS)
	for x in [-1, Constants.GRID_WIDTH]:
		for y in range(0, Constants.GRID_HEIGHT):
			spawn_rail(Vector2i(x, y), Constants.RailType.OUT_OF_BOUNDS)

func spawn_rail(position: Vector2i, rail_type: Constants.RailType):
	var rail_instance = piece_scene.instantiate()
	rail_instance.position = Constants.RAIL_OFFSET + (position * Constants.CELL_SIZE_P)
	rail_instance.target_rotation = (randi() % 4) * 90
	rail_instance.rail_type = rail_type
	rail_instance.coordinate = position
	main.add_child(rail_instance)
	rail_instances.set(position, rail_instance)

func get_rail(position: Vector2i) -> Track:
	return rail_instances[position]

func grid_contains(position: Vector2i) -> bool:
	return rail_instances.has(position)

func find_spawn_location(spawn_origin_dir: Constants.Side = Constants.Side.LEFT) -> SpawnInstruction:
	var viable_rail_vectors = []
	for i in range(Constants.GRID_HEIGHT):
		var rail_key = Vector2i(0, i)
		var rail = get_rail(rail_key)
		var can_enter = rail.train_can_enter(spawn_origin_dir)
		if can_enter:
			viable_rail_vectors.append(rail_key)
	if len(viable_rail_vectors) == 0:
		return null
		print("Train couldn't enter any rails")
	var rail_index = randi() % len(viable_rail_vectors)
	var viable_rail_vector = viable_rail_vectors[rail_index]
	# Find the spawn location leading to this rail
	match spawn_origin_dir:
		Constants.Side.LEFT:
			viable_rail_vector -= Vector2i(1, 0)
		Constants.Side.RIGHT:
			viable_rail_vector += Vector2i(1, 0)
		Constants.Side.TOP:
			viable_rail_vector -= Vector2i(0, 1)
		Constants.Side.BOTTOM:
			viable_rail_vector += Vector2i(0, 1)
	var first: Track = get_rail(viable_rail_vector)
	var second: Track = get_rail(viable_rail_vector + Vector2i(1, 0))
	var spawnDef = SpawnInstruction.new(first, second, Constants.Direction.EAST)
	return spawnDef
