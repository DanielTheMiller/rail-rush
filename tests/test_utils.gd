class_name TestUtils

static func PopulateGridWithHorizontalRails(grid_service: GridService) -> void:
	var latest_cell: Vector2i
	for x in range(0, Constants.GRID_WIDTH):
		for y in range(0, Constants.GRID_HEIGHT):
			latest_cell = Vector2i(x,y)
			grid_service.spawn_rail(latest_cell, Constants.RailType.STRAIGHT)
			var rail: Track = grid_service.get_rail(latest_cell)
			rail.rotation_degrees = 90
			rail.target_rotation = 90
	print("The last cell created was at %s" % latest_cell)

static func PopulateGridWithVerticalRails(grid_service: GridService) -> void:
	var latest_cell: Vector2i
	for x in range(0, Constants.GRID_WIDTH):
		for y in range(0, Constants.GRID_HEIGHT):
			latest_cell = Vector2i(x,y)
			grid_service.spawn_rail(latest_cell, Constants.RailType.STRAIGHT)
			var rail: Track = grid_service.get_rail(latest_cell)
			rail.rotation_degrees = 0
			rail.target_rotation = 0
	print("The last cell created was at %s" % latest_cell)
