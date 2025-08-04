extends Node2D

# Preload the rail scene
var train_scene := preload("res://actors/train.tscn")

var grid_service = preload("res://services/grid_service.gd").new(self)

var train_instance: Train
var train_instances: Dictionary = {} # Implement that

func _ready():
	grid_service.create_game_grid()
	init_train()
	run()
	
func init_train():
	# Find the first straight rail on the left to feed a train into
	var spawn_location: SpawnInstruction = grid_service.find_spawn_location()
	print("Spawn location is %s" % spawn_location.get_first_vector())
	while (spawn_location == null):
		print("Cannot find ready rail!")
		await get_tree().create_timer(.5).timeout
		spawn_location = grid_service.find_spawn_location()
	var ready_rail: Track = spawn_location.first_rail
	var target_rail: Track = spawn_location.second_rail
	ready_rail.lock_track()
	target_rail.lock_track()
	train_instance = train_scene.instantiate()
	train_instance.set_current_rail(ready_rail)
	train_instance.set_next_target_rail(target_rail)
	add_child(train_instance)
	var train_id: String = UUID.create_new()
	train_instances.set(train_id, train_instance)
	await train_instance.spawn_train()
	print("Train spawned")

func run():
	while true:	
		for train_id in train_instances:
			var train_instance = train_instances[train_id]
			train_instance.move() # Don't await		
		await get_tree().create_timer(Constants.TRAIN_MOVE_TIME_S).timeout
		for train_id in train_instances:
			var train_instance = train_instances[train_id]
			train_instance.set_current_to_target()
			var exit_dir = train_instance.get_exit_direction_of_current_rail()
			if exit_dir == Constants.Direction.NULL:
				print("DERAIL: NO VALID CONNECTION")
				respawn_train(train_id)
				continue
			train_instance.travelling_direction = exit_dir
			var movement_vector = Constants.get_movement_vector_from_dir(exit_dir)
			var next_vector = train_instance.current_rail_vector + movement_vector
			print("Current movement vector is %s, and the next actual vector is %s" % [movement_vector, next_vector])
			if not grid_service.grid_contains(next_vector):
				print("DERAIL: NO TRACK AT NEXT VECTOR")
				respawn_train(train_id)
				continue
			var next_rail: Node2D = grid_service.get_rail(next_vector)
			# Does the next rail have an ideal rotation to move into?
			if not next_rail_aligned(exit_dir, next_rail):
				print("DERAIL: NEXT TRACK NOT ALIGNED")
				respawn_train(train_id)
				continue
			var previous_rail = train_instance.current_rail
			if previous_rail != null:
				previous_rail.unlock_track()
			next_rail.lock_track()
			train_instance.set_next_target_rail(next_vector, next_rail)

func respawn_train(train_id: String):
	destroy_train(train_id)
	print("Waiting a few seconds before respawning train")
	await get_tree().create_timer(Constants.TRAIN_MOVE_TIME_S).timeout # Little timer between respawn
	await init_train()

func destroy_train(train_id: String):
	var train_instance = train_instances.get(train_id)
	if train_instance.target_rail != null:
		train_instance.target_rail.unlock_track()
	if train_instance.current_rail != null:
		train_instance.current_rail.unlock_track()
	train_instances.erase(train_id)
	remove_child(train_instance)

# Returns a bool representing whether the current rail connects to the next rail
func next_rail_aligned(exit_dir: Constants.Direction, next_rail: Node2D) -> bool:
	var entrance_side: Constants.Side
	match exit_dir:
		Constants.Direction.NORTH:
			entrance_side = Constants.Side.BOTTOM
		Constants.Direction.WEST:
			entrance_side = Constants.Side.RIGHT
		Constants.Direction.EAST:
			entrance_side = Constants.Side.LEFT
		Constants.Direction.SOUTH:
			entrance_side = Constants.Side.TOP
		_:
			print("NO EXIT DIR PROVIDED TO ALIGNMENT CHECKER")
			return false
	return next_rail.train_can_enter(entrance_side)
