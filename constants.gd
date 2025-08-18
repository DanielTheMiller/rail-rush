class_name Constants
enum Side {
	TOP,
	LEFT,
	RIGHT,
	BOTTOM,
	NULL
}

enum RailType {
	STRAIGHT,
	CURVE,
	OUT_OF_BOUNDS
}

enum Direction {
	NORTH,
	SOUTH,
	EAST,
	WEST,
	NULL
}

enum InstructionType {
	START,
	SPAWN_TRAIN,
	SPAWN_COIN,
	WAIT,
	END_LEVEL,
	GOTO
}

const GRID_HEIGHT = 10
const GRID_WIDTH = 10
const CELL_SIZE_P = 50
const TRAIN_HORIZ_POS_OFFSET = Vector2(0, -7) # Train offset while traveling horizontally
const RAIL_OFFSET = Vector2i(25,25) # How offset the rail image should be on the rail tiles

# How long in seconds does it take for a train to move from cell to cell
const TRAIN_MOVE_TIME_S = 1

static func convert_exit_side_to_dir(side: Side):
	match side:
		Side.TOP:
			return Direction.NORTH
		Side.BOTTOM:
			return Direction.SOUTH
		Side.LEFT:
			return Direction.WEST
		Side.RIGHT:
			return Direction.EAST
		_:
			print("COULD NOT PARSE DIRECTION FROM SIDE %s"%side)
			push_error("Could not parse direction from side %s"%side)
			return Direction.NULL

static func convert_dir_to_exit_side(direction: Direction):
	match direction:
		Constants.Direction.EAST:
			return 	Constants.Side.RIGHT
		Constants.Direction.WEST:
			return Constants.Side.LEFT
		Constants.Direction.NORTH:
			return Constants.Side.TOP
		Constants.Direction.SOUTH:
			return Constants.Side.BOTTOM
		_:
			push_error("Could not parse side from direction %s"%direction)
			return Constants.Side.NULL

static func convert_dir_to_entrance_side(direction: Direction):
	match direction:
		Constants.Direction.EAST:
			return 	Constants.Side.LEFT
		Constants.Direction.WEST:
			return Constants.Side.RIGHT
		Constants.Direction.NORTH:
			return Constants.Side.BOTTOM
		Constants.Direction.SOUTH:
			return Constants.Side.TOP
		_:
			push_error("Could not parse side from direction %s"%direction)
			return Constants.Side.NULL

static func get_movement_vector_from_dir(dir: Direction) -> Vector2i:
	match dir:
		Constants.Direction.NORTH:
			return Vector2i(0, -1)
		Constants.Direction.SOUTH:			
			return Vector2i(0, 1)
		Constants.Direction.WEST:
			return Vector2i(-1, 0)
		Constants.Direction.EAST:
			return Vector2i(1, 0)
		_:
			print("CANNOT FIND EXIT DIR (%s)" % dir)
			push_error("CANNOT FIND EXIT DIR %s", dir)
			return Vector2i(0,0)
