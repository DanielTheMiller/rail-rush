extends Node2D

# Preload the rail scene
var train_scene := preload("res://actors/train.tscn")
var piece_scene := preload("res://tiles/track_piece.tscn")

var train_instance: Node2D
var rail_instances: Dictionary = {}
var train_instances: Dictionary = {} # Implement that

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
	var ready_rail_vector: Vector2i = find_spawning_rail_vector()
	while(ready_rail_vector == Vector2i(-1, -1)):
		print("Cannot find ready rail!")
		await get_tree().create_timer(.5).timeout
		ready_rail_vector = find_spawning_rail_vector()
	var ready_rail: Node2D = rail_instances[ready_rail_vector]
	ready_rail.lock_track()
	train_instance = train_scene.instantiate()
	train_instance.current_rail_vector = ready_rail_vector
	train_instance.set_target_rail(ready_rail)
	add_child(train_instance)
	var train_id: String = UUID.create_new()
	train_instances.set(train_id, train_instance)
	await train_instance.spawn_train()
	print("Train spawned")

func find_spawning_rail_vector() -> Vector2i:
	var viable_rails = []
	for i in range(Constants.GRID_HEIGHT):
		var rail_key = Vector2i(0, i)
		var rail = rail_instances[rail_key]
		var can_enter = rail.train_can_enter(Constants.Side.LEFT)
		if can_enter:
			viable_rails.append(rail_key)
	if len(viable_rails) == 0:
		return Vector2i(-1,-1)
		print("Train couldn't enter any rails")
	var rail_index = randi() % len(viable_rails)
	return viable_rails[rail_index]

func run():
	while true:	
		for train_id in train_instances:
			var train_instance = train_instances[train_id]
			var exit_dir = train_instance.get_direction_of_next_rail()
			if exit_dir == Constants.Direction.NULL:
				print("DERAIL: NO VALID CONNECTION")
				await respawn_train(train_id)
				continue
			train_instance.travelling_direction = exit_dir
			var movement_vector = Constants.get_movement_vector_from_dir(exit_dir)
			var next_vector = train_instance.current_rail_vector + movement_vector
			print("Current movement vector is %s, and the next actual vector is %s" % [movement_vector, next_vector])
			if not rail_instances.has(next_vector):
				print("DERAIL: NO TRACK AT NEXT VECTOR")
				await respawn_train(train_id)
				continue
			var next_rail: Node2D = rail_instances[next_vector]
			# Does the next rail have an ideal rotation to move into?
			if not next_rail_aligned(exit_dir, next_rail):
				print("DERAIL: NEXT TRACK NOT ALIGNED")
				await respawn_train(train_id)
				continue
			next_rail.lock_track()
			var previous_rail = train_instance.current_rail
			train_instance.set_target_rail(next_rail)
			await train_instance.move()
			train_instance.current_rail_vector = next_vector
			previous_rail.unlock_track()

func respawn_train(train_id: String):
	destroy_train(train_id)
	await get_tree().create_timer(Constants.TRAIN_MOVE_TIME_S).timeout # Little timer between respawn
	await init_train()

func destroy_train(train_id: String):
	var train_instance = train_instances.get(train_id)
	train_instance.current_rail.unlock_track()
	train_instances.erase(train_id)
	remove_child(train_instance)

# Returns a bool representing whether the current rail connects to the next rail
func next_rail_aligned(exit_dir: Constants.Direction, next_rail: Node2D) -> bool:
	var entrance_side: Constants.Side
	match exit_dir:
		Constants.Direction.NORTH:
			entrance_side = Constants.Side.BOTTOM
		Constants.Direction.WEST:
			entrance_side = Constants.Side.RIGHT
		Constants.Direction.EAST:
			entrance_side = Constants.Side.LEFT
		Constants.Direction.SOUTH:
			entrance_side = Constants.Side.TOP
		_:
			print("NO EXIT DIR PROVIDED TO ALIGNMENT CHECKER")
			return false
	return next_rail.train_can_enter(entrance_side)
