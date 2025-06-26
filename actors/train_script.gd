extends Node2D

@export var current_rail: Node2D
@export var travelling_direction: Constants.Direction = Constants.Direction.EAST
var move_duration_s: int = 3
var target_rail = Node2D

func _ready() -> void:
	spawn_train()
	
func spawn_train() -> void:
	match travelling_direction:
		Constants.Direction.EAST:
			# Spawn from left
			position = current_rail.position - Vector2(Constants.CELL_SIZE_P, 0) + Constants.TRAIN_HORIZ_POS_OFFSET
			var tween = create_tween()
			tween.tween_property(self, "position", current_rail.position + Constants.TRAIN_HORIZ_POS_OFFSET, move_duration_s)
			await get_tree().create_timer(move_duration_s).timeout
			turn_if_required()
			return
		_:
			push_error("Cannot spawn train travelling %s" % travelling_direction)
			return

func move() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", target_rail.position + Constants.TRAIN_HORIZ_POS_OFFSET, move_duration_s)
	await get_tree().create_timer(move_duration_s).timeout
	current_rail = target_rail

# Given the current moving direction
# Analyse the current rail direction, change our direction to match
func turn_if_required() -> void:
	var exit_side: Constants.Direction = current_rail.get_exit_side_from_travel_direction(travelling_direction)

func set_target_rail(rail: Node2D) -> void:
	target_rail = rail

# Get the direction that the proceeding rail is
func get_direction_of_next_rail() -> Constants.Direction:
	var exit_side = current_rail.get_exit_side_from_travel_direction(travelling_direction)
	return Constants.convert_exit_side_to_dir(exit_side)
