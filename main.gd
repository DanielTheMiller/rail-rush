extends Node2D

# Preload the rail scene
var train_scene := preload("res://actors/train.tscn")
var piece_scene := preload("res://tiles/track_piece.tscn")

var train_instance: Node2D
var current_rail_vector: Vector2i
var rail_instances:Dictionary = {}

const RAIL_OFFSET = Vector2i(25,25)

func _ready():
	create_game_grid()
	await init_train()
	run()
	
func create_game_grid():
	for x in range(0, Constants.GRID_WIDTH):
		for y in range(0, Constants.GRID_HEIGHT):
			spawn_rail(Vector2i(x, y))
		
func spawn_rail(position: Vector2i):
	var no_of_rail_types: int = len(Constants.RailType.values())
	var rail_type: Constants.RailType = Constants.RailType.values()[randi() % no_of_rail_types]
	var rail_instance = piece_scene.instantiate()
	rail_instance.position = RAIL_OFFSET + (position * Constants.CELL_SIZE_P)
	rail_instance.target_rotation = (randi() % 4) * 90
	rail_instance.rail_type = rail_type
	rail_instance.coordinate = position
	add_child(rail_instance)
	rail_instances.set(position, rail_instance)
	
func init_train():
	# Find the first straight rail on the left to feed a train into
	var ready_rail = find_spawning_rail()
	while(ready_rail == null):
		print("Cannot find ready rail!")
		await get_tree().create_timer(.5).timeout
		ready_rail = find_spawning_rail()
	ready_rail.lock_track()
	train_instance = train_scene.instantiate()
	train_instance.set_target_rail(ready_rail)
	add_child(train_instance)
	await train_instance.spawn_train()
	print("Train spawned")

func find_spawning_rail():
	var viable_rails = []
	for i in range(Constants.GRID_HEIGHT):
		var rail_key = Vector2i(0, i)
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
		print("---\n%s"%Time.get_ticks_msec())
		get_tree().create_timer(Constants.TRAIN_MOVE_TIME_S).timeout
		var exit_dir = train_instance.get_direction_of_next_rail()
		if exit_dir == Constants.Direction.NULL:
			print("No valid track connection. Destroying train")
			destroy_train()
			init_train()
			continue
		train_instance.travelling_direction = exit_dir
		var movement_vector = Constants.get_movement_vector_from_dir(exit_dir)
		var next_vector = current_rail_vector + movement_vector
		print("Current movement vector is %s, and the next actual vector is %s" % [movement_vector, next_vector])
		if not rail_instances.has(next_vector):
			print("Cannot find next rail! Destroying train")
			destroy_train()
			init_train()
			continue
		var next_rail: Node2D = rail_instances[next_vector]
		next_rail.lock_track()
		var previous_rail = train_instance.current_rail
		train_instance.set_target_rail(next_rail)
		await train_instance.move()
		current_rail_vector = next_vector
		previous_rail.unlock_track()

func destroy_train():
	train_instance.current_rail.unlock_track()
	remove_child(train_instance)
