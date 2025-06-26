extends Node2D

# Preload the rail scene
var train_scene := preload("res://actors/train.tscn")
var piece_scene := preload("res://tiles/track_piece.tscn")

var train_instance: Node2D
var current_rail_vector: Vector2i
var rail_instances:Dictionary = {}

const RAIL_OFFSET = Vector2i(25,25)

func _ready():
	var grid_max_w_p: int = Constants.CELL_SIZE_P * Constants.GRID_WIDTH
	var grid_max_h_p: int = Constants.CELL_SIZE_P * Constants.GRID_HEIGHT
	for x in range(0, grid_max_w_p, Constants.CELL_SIZE_P):
		for y in range(0, grid_max_h_p, Constants.CELL_SIZE_P):
			spawn_rail(Vector2i(x, y))
	init_train()
	run()
		
func spawn_rail(position: Vector2i):
	var no_of_rail_types: int = len(Constants.RailType.values())
	var rail_type: Constants.RailType = Constants.RailType.values()[randi() % no_of_rail_types]
	var rail_instance = piece_scene.instantiate()
	rail_instance.position = RAIL_OFFSET + position
	rail_instance.target_rotation = (randi() % 4) * 90
	rail_instance.rail_type = rail_type
	add_child(rail_instance)
	rail_instances.set(position, rail_instance)
	
func init_train():
	# Find the first straight rail on the left to feed a train into
	var ready_rail = find_ready_rail()
	while(ready_rail == null):
		print("Cannot find ready rail!")
		await get_tree().create_timer(.5).timeout
		ready_rail = find_ready_rail()
	ready_rail.lock_track()
	get_tree().create_timer(5).timeout
	train_instance = train_scene.instantiate()
	train_instance.current_rail = ready_rail
	add_child(train_instance)
	print("Train spawned")

func find_ready_rail():
	var viable_rails = []
	for i in range(Constants.GRID_HEIGHT):
		var rail_key = Vector2i(0, i * Constants.CELL_SIZE_P)
		var rail = rail_instances[rail_key]
		var can_enter = rail.train_can_enter(Constants.Side.LEFT)
		if can_enter:
			viable_rails.append(rail_key)
	if len(viable_rails) == 0:
		return null
		print("Train couldn't enter any rails")
	var rail_index = randi() % len(viable_rails)
	current_rail_vector = viable_rails[rail_index]
	return rail_instances[current_rail_vector]

func run():
	while true:	
		get_tree().create_timer(5).timeout
		var next_rail = find_next_rail()
		train_instance.set_target_rail(next_rail)
		train_instance.move()
		
func find_next_rail():
	var exit_dir: Constants.Direction = train_instance.get_direction_of_next_rail()
	var next_rail_vector: Vector2i
	match exit_dir:
		Constants.Direction.NORTH:
			next_rail_vector = current_rail_vector + Vector2i(0, -1 * Constants.CELL_SIZE_P)
		Constants.Direction.SOUTH:			
			next_rail_vector = current_rail_vector + Vector2i(0, 1 * Constants.CELL_SIZE_P)
		Constants.Direction.WEST:
			next_rail_vector = current_rail_vector + Vector2i(-1 * Constants.CELL_SIZE_P, 0)
		Constants.Direction.EAST:
			next_rail_vector = current_rail_vector + Vector2i(1 * Constants.CELL_SIZE_P, 0)
		_:
			push_error("CANNOT FIND EXIT DIR %s", exit_dir)
	if not rail_instances.has(next_rail_vector):
		# log("Train is leaving the map!")
		return
	return rail_instances[next_rail_vector]
