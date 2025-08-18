extends GutTest

var train_scene := preload("res://actors/train.tscn")
const HORIZONTAL_ROTATION = 90
	
#Setup a grid with only 3 tiles, only 3 in a line
func test_train_can_leave_map_west():
	# Setup - 
	var grid_service = preload("res://services/grid_service.gd").new(self, false)
	grid_service.spawn_rail(Vector2i(-1,0), Constants.RailType.OUT_OF_BOUNDS, HORIZONTAL_ROTATION)
	grid_service.spawn_rail(Vector2i(0,0), Constants.RailType.STRAIGHT, HORIZONTAL_ROTATION)
	grid_service.spawn_rail(Vector2i(1,0), Constants.RailType.STRAIGHT, HORIZONTAL_ROTATION)
	var spawn_rail = grid_service.get_rail(Vector2i(1,0))
	var next_rail = grid_service.get_rail(Vector2i(0,0))
	var train: Train = train_scene.instantiate()
	var spawn_instruction: SpawnInstruction = SpawnInstruction.new(spawn_rail, next_rail, Constants.Direction.WEST)
	# Act
	train.set_spawn_location(spawn_instruction)
	add_child(train)
	await train.spawn_train()
	# Assert
	await train.move()
	await get_tree().create_timer(Constants.TRAIN_MOVE_TIME_S).timeout
	var derailed = train.find_and_set_next_target_rail(grid_service)
	assert_false(derailed, "Expected the train not to derail in finding the exit point")
	# We don't need to make the train leave the course to prove this, but satisfying to watch
	if not derailed:
		await train.move()
		await get_tree().create_timer(Constants.TRAIN_MOVE_TIME_S).timeout
	grid_service.destroy()

# Ensure that 3 trains can spawn and all reach their destinations in good time
# Smooth journeys, no haulting
func test_3_trains_spawn_and_despawn_in_good_time():
	# My wonder for this is: can we leverage the main script?
	# Can we make the main game loop invoke a sort of next_move() method?
	# Th
