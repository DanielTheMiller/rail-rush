extends Node2D

@export var travelling_direction: Constants.Direction = Constants.Direction.EAST
var move_duration_s: int = Constants.TRAIN_MOVE_TIME_S # In variable for flexibility
var current_rail: Node2D
var target_rail: Node2D
@export var current_rail_vector: Vector2i
@export var target_rail_vector: Vector2i
@export var desired_destination: Constants.Direction = Constants.Direction.WEST

func spawn_train() -> void:
	match travelling_direction:
		Constants.Direction.EAST:
			# Spawn from left
			position = target_rail.position - Vector2(Constants.CELL_SIZE_P, 0) + Constants.TRAIN_HORIZ_POS_OFFSET
		_:
			push_error("Cannot spawn train travelling %s" % travelling_direction)
			return

func move() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", target_rail.position + Constants.TRAIN_HORIZ_POS_OFFSET, move_duration_s)
	turn_if_required()
	await get_tree().create_timer(move_duration_s).timeout

# Given the current moving direction
# Analyse the current rail direction, change our direction to match
func turn_if_required() -> void:
	if current_rail == null:
		return # This train is spawning, doesn't need to turn yet
	var exit_side: Constants.Direction = current_rail.get_exit_side_from_travel_direction(travelling_direction)

func set_current_to_target() -> void:
	current_rail = target_rail
	current_rail_vector = target_rail_vector
	target_rail = null
	target_rail_vector = Vector2i(-1,-1)

func set_next_target_rail(rail_vector: Vector2i, rail: Node2D) -> void:
	target_rail = rail
	target_rail_vector = rail_vector

# Get the direction that the proceeding rail is
func get_exit_direction_of_current_rail() -> Constants.Direction:
	if current_rail == null:
		# Train is spawning, return current travelling direction
		return travelling_direction
	var exit_side = current_rail.get_exit_side_from_travel_direction(travelling_direction)
	return Constants.convert_exit_side_to_dir(exit_side)
