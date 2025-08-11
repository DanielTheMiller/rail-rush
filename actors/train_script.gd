class_name Train extends Node2D

@export var travelling_direction: Constants.Direction = Constants.Direction.EAST
var move_duration_s: int = Constants.TRAIN_MOVE_TIME_S # In variable for flexibility
var current_rail: Track
var target_rail: Track
@export var desired_destination: Constants.Direction = Constants.Direction.WEST

func spawn_train() -> void:
	position = current_rail.position + Constants.TRAIN_HORIZ_POS_OFFSET

func move() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", target_rail.position + Constants.TRAIN_HORIZ_POS_OFFSET, move_duration_s)
	turn_if_required()
	#await get_tree().create_timer(move_duration_s).timeout

# Given the current moving direction
# Analyse the current rail direction, change our direction to match
func turn_if_required() -> void:
	if current_rail == null:
		return # This train is spawning, doesn't need to turn yet
	var exit_side: Constants.Side = current_rail.get_exit_side_from_travel_direction(travelling_direction)

func set_current_to_target() -> void:
	if current_rail != null:
		current_rail.unlock_track()
	current_rail = target_rail
	target_rail = null

func set_spawn_location(spawn_def: SpawnInstruction) -> void:
	current_rail = spawn_def.first_rail
	target_rail = spawn_def.second_rail
	travelling_direction = spawn_def.direction

func set_next_target_rail(rail: Track) -> void:
	target_rail = rail

# Get the direction that the proceeding rail is
func get_exit_direction_of_current_rail() -> Constants.Direction:
	if current_rail == null:
		# Train is spawning, return current travelling direction
		return travelling_direction
	var exit_side = current_rail.get_exit_side_from_travel_direction(travelling_direction)
	return Constants.convert_exit_side_to_dir(exit_side)

# Finds the next rail piece sets it as the target rail, using the current direction.
# Returns a derailment bool - true if the train derailed
func find_and_set_next_target_rail(grid_service: GridService) -> bool:
	set_current_to_target()
	var exit_dir = get_exit_direction_of_current_rail()
	if exit_dir == Constants.Direction.NULL:
		print("DERAIL: NO VALID CONNECTION")
		return true
	travelling_direction = exit_dir
	var movement_vector = Constants.get_movement_vector_from_dir(exit_dir)
	var next_vector = current_rail.coordinate + movement_vector
	print("Current movement vector is %s, and the next actual vector is %s" % [movement_vector, next_vector])
	if not grid_service.grid_contains(next_vector):
		print("DERAIL: NO TRACK AT NEXT VECTOR")
		return true
	var next_rail: Node2D = grid_service.get_rail(next_vector)
	# Does the next rail have an ideal rotation to move into?
	var entrance_side = Utils.get_entrance_side_from_direction(exit_dir)
	if not next_rail.train_can_enter(entrance_side):
		print("DERAIL: NEXT TRACK NOT ALIGNED")
		return true
	next_rail.lock_track()
	set_next_target_rail(next_rail)
	return false
