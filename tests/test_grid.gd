extends GutTest

func test_grid_contains_all_cells():
	# Setup
	var mock_node = Node2D.new() # Create Node2d
	var grid_service = preload("res://services/grid_service.gd").new(mock_node)
#	var grid_service = grid_service_scene.new(mock_node)
	var min_coord = Vector2i(0,0)
	var max_coord = Vector2i(Constants.GRID_WIDTH-1, Constants.GRID_HEIGHT-1)
	# Act & Assert
	assert_true(grid_service.grid_contains(min_coord), "Grid lacks the minimum coord")
	assert_true(grid_service.grid_contains(max_coord), "Grid lacks the max coord")

func test_grid_contains_spawning_and_exit_points():
	# Setup
	var mock_node = Node2D.new() # Create Node2d
	var grid_service = preload("res://services/grid_service.gd").new(mock_node)
	# Assert
	for y_coord in range(Constants.GRID_HEIGHT):
		var left_coord: Vector2i = Vector2i(-1, y_coord)
		assert_true(grid_service.grid_contains((left_coord)), "Grid doesn't contain left spawn %s" % left_coord)
		var right_coord: Vector2i = Vector2i(Constants.GRID_WIDTH, y_coord)
		assert_true(grid_service.grid_contains((right_coord)), "Grid doesn't contain right spawn %s" % right_coord)
	for x_coord in range(Constants.GRID_WIDTH):
		var top_coord: Vector2i = Vector2i(x_coord, -1)
		var bottom_coord: Vector2i = Vector2i(x_coord, Constants.GRID_HEIGHT)
		assert_true(grid_service.grid_contains((top_coord)), "Grid doesn't contain top spawn %s" % top_coord)
		assert_true(grid_service.grid_contains((bottom_coord)), "Grid doesn't contain bottom spawn %s" % bottom_coord)

# Ensure that the actual play pieces start at x0 y0
# This is a useful definition, and useful to enforce
func test_game_grid_begins_at_x0y0():
	# Setup
	var mock_node = Node2D.new() # Create Node2d
	var grid_service = preload("res://services/grid_service.gd").new(mock_node)
	# Act
	var spawn_rail1 = null
	if (grid_service.grid_contains(Vector2i(-1,-1))):	
		spawn_rail1 = grid_service.get_rail(Vector2i(-1,-1))
	var first_rail = grid_service.get_rail(Vector2i(0,0))
	var spawn_rail2 = grid_service.get_rail(Vector2i(0,-1))
	var spawn_rail3 = grid_service.get_rail(Vector2i(-1,0))
	# Assert
	assert_not_null(first_rail, "The first tile is missing!")
	assert_not_same(Constants.RailType.OUT_OF_BOUNDS, first_rail.rail_type, "Expected the first rail to be a game piece - but it's a spawn point!")
	if (spawn_rail1):
		assert_eq(Constants.RailType.OUT_OF_BOUNDS, spawn_rail1.rail_type, "Expected not to find a game piece outside of game bounds!")
	assert_eq(Constants.RailType.OUT_OF_BOUNDS, spawn_rail2.rail_type, "Expected not to find a game piece outside of game bounds!")
	assert_eq(Constants.RailType.OUT_OF_BOUNDS, spawn_rail3.rail_type, "Expected not to find a game piece outside of game bounds!")

# Ensure that the method for finding a way into the grid returns 2 rail vectors
# These rail vectors need to be right next to each other, and the direction enum
# must be pointing the train the right way to the target rail 
func test_find_spawning_rail_vector():
	# Setup
	var mock_node = Node2D.new() # Create Node2d
	var grid_service: GridService = preload("res://services/grid_service.gd").new(mock_node)
	# Act
	grid_service.find_spawn_location()
