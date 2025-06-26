extends Node2D
const Constants := preload("res://constants.gd")
var main := preload("res://main.gd")

@export var rail_type: Constants.RailType = Constants.RailType.STRAIGHT
@export var target_rotation: int = -1

var is_locked: bool = false # Use to disable user-interaction with this cell
var current_tween = create_tween()
var operation_underway = false

func _ready() -> void:
	if (rail_type == Constants.RailType.CURVE):
		var texture: TextureRect = get_child(0)
		texture.texture = load("res://images/Curve.png")
	rotation_degrees = target_rotation

func lock_track() -> void:
	print("Locking track at %s" % position)
	is_locked = true
	
func unlock_track() -> void:
	is_locked = false

func spin(clockwise: bool) -> void:
	print("Spinning track at %s" % position)
	if operation_underway or is_locked:
		return
	operation_underway = true
	if target_rotation == -1:
		target_rotation = int(rotation_degrees)
	current_tween.kill();
	current_tween = create_tween();
	var iteration = 90 * (1 if clockwise else -1)
	target_rotation += iteration
	current_tween.tween_property(self, "rotation_degrees", target_rotation, 0.5).set_trans(Tween.TRANS_BACK)
	await get_tree().create_timer(.5).timeout
	operation_underway = false

func train_can_enter(side: Constants.Side) -> bool:
	var connected_sides: Array = get_connected_sides();
	return connected_sides.has(side);

func get_exit_side_from_travel_direction(direction: Constants.Direction) -> Constants.Side:
	var entrance_side: Constants.Side = Constants.convert_dir_to_entrance_side(direction)
	return get_exit_side_from_entrance(entrance_side)
	
## Returns a side or null
func get_exit_side_from_entrance(side: Constants.Side) -> Constants.Side:
	var connected_sides: Array = get_connected_sides();
	var index_of_entrance = connected_sides.find(side, 0)
	if (index_of_entrance == -1):
		return Constants.Side.NULL
	var other_side_index = 1 - index_of_entrance
	return connected_sides[other_side_index]

func get_connected_sides() -> Array:
	match rail_type:
		Constants.RailType.STRAIGHT:
			match target_rotation % 360:
				0, 180, -180:
					return [Constants.Side.TOP, Constants.Side.BOTTOM]
				90, -270, 270, -90:
					return [Constants.Side.LEFT, Constants.Side.RIGHT]
				_:
					push_error("Invalid rotation angle %s", target_rotation)
					return []
		Constants.RailType.CURVE:
			match target_rotation % 360:
				0:
					return [Constants.Side.LEFT, Constants.Side.TOP]
				-270, 90:
					return [Constants.Side.TOP, Constants.Side.RIGHT]
				-180, 180:
					return [Constants.Side.RIGHT, Constants.Side.BOTTOM]
				-90, 270:
					return [Constants.Side.LEFT, Constants.Side.BOTTOM]
				_:
					push_error("Invalid rotation angle %s", target_rotation)
					return []
		_:
			push_error("Unrecognised rail type: %s", rail_type)
			return []
