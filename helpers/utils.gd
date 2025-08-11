class_name Utils

static func get_entrance_side_from_direction(travel_dir: Constants.Direction) -> Constants.Side:
	var entrance_side: Constants.Side = Constants.Side.NULL
	match travel_dir:
		Constants.Direction.NORTH:
			entrance_side = Constants.Side.BOTTOM
		Constants.Direction.WEST:
			entrance_side = Constants.Side.RIGHT
		Constants.Direction.EAST:
			entrance_side = Constants.Side.LEFT
		Constants.Direction.SOUTH:
			entrance_side = Constants.Side.TOP
		_:
			assert(travel_dir < len(Constants.Direction.values()), "Invalid Direction Provided")
	return entrance_side
