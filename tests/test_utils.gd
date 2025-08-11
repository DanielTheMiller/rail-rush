class_name TestUtils

const VERTICAL_ROTATION = 0;
const HORIZONTAL_ROTATION = 90;

static func PopulateGridWithHorizontalRails(grid_service: GridService) -> void:
	var latest_cell: Vector2i
	for x in range(0, Constants.GRID_WIDTH):
		for y in range(0, Constants.GRID_HEIGHT):
			latest_cell = Vector2i(x,y)
			spawn_rail(grid_service, latest_cell, Constants.RailType.OUT_OF_BOUNDS, HORIZONTAL_ROTATION)
		# Create the rails for de/spawning on
		for y in [-1, Constants.GRID_HEIGHT]:
			spawn_rail(grid_service, Vector2i(x, y), Constants.RailType.OUT_OF_BOUNDS, HORIZONTAL_ROTATION)
	for x in [-1, Constants.GRID_WIDTH]:
		for y in range(0, Constants.GRID_HEIGHT):
			spawn_rail(grid_service, Vector2i(x, y), Constants.RailType.OUT_OF_BOUNDS, HORIZONTAL_ROTATION)
	print("The last cell created was at %s" % latest_cell)

static func PopulateGridWithVerticalRails(grid_service: GridService) -> void:
	var latest_cell: Vector2i
	for x in range(0, Constants.GRID_WIDTH):
		for y in range(0, Constants.GRID_HEIGHT):
			latest_cell = Vector2i(x,y)
			spawn_rail(grid_service, latest_cell, Constants.RailType.STRAIGHT, VERTICAL_ROTATION)
		# Create the rails for de/spawning on
		for y in [-1, Constants.GRID_HEIGHT]:
			spawn_rail(grid_service, Vector2i(x, y), Constants.RailType.OUT_OF_BOUNDS, VERTICAL_ROTATION)
	for x in [-1, Constants.GRID_WIDTH]:
		for y in range(0, Constants.GRID_HEIGHT):
			spawn_rail(grid_service, Vector2i(x, y), Constants.RailType.OUT_OF_BOUNDS, VERTICAL_ROTATION)
	print("The last cell created was at %s" % latest_cell)

static func spawn_rail(grid_service: GridService, cell: Vector2i, rail_type: Constants.RailType,
rotation: int):
	grid_service.spawn_rail(cell, rail_type)
	var rail: Track = grid_service.get_rail(cell)
	rail.rotation_degrees = rotation
	rail.target_rotation = rotation
