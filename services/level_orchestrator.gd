class_name LevelOrchestrator

# Preload the rail scene
var train_scene := preload("res://actors/train.tscn")
var grid_service: GridService
var main: Node

var train_instances: Dictionary = {}
var max_train_count = 10

func _init(main_param: Node):
	self.main = main_param

func _ready():
	grid_service = preload("res://services/grid_service.gd").new(self)
	run()
	
func init_train():
	# Find the first straight rail on the left to feed a train into
	var spawn_location: SpawnInstruction = grid_service.find_spawn_location()
	while (spawn_location == null):
		print("Cannot find ready rail!")
		await main.get_tree().create_timer(.5).timeout
		spawn_location = grid_service.find_spawn_location()
	print("Spawn location is %s" % spawn_location.first_rail)
	var ready_rail: Track = spawn_location.first_rail
	var target_rail: Track = spawn_location.second_rail
	ready_rail.lock_track()
	target_rail.lock_track()
	var train_instance: Train = train_scene.instantiate()
	train_instance.set_spawn_location(spawn_location)
	main.add_child(train_instance)
	var train_id: String = UUID.create_new()
	train_instances.set(train_id, train_instance)
	await train_instance.spawn_train()
	print("Train spawned")

func run():
	while true:	
		if len(train_instances) < max_train_count:
			init_train()
		for train_id in train_instances:
			var train_instance: Train = train_instances[train_id]
			train_instance.move() # Don't await
		await main.get_tree().create_timer(Constants.TRAIN_MOVE_TIME_S).timeout
		for train_id in train_instances:
			var train_instance: Train = train_instances[train_id]
			var derailed = train_instance.find_and_set_next_target_rail(grid_service)
			if derailed:
				destroy_train(train_id)


func destroy_train(train_id: String):
	var train_instance: Train = train_instances.get(train_id)
	if train_instance.target_rail != null:
		train_instance.target_rail.unlock_track()
	if train_instance.current_rail != null:
		train_instance.current_rail.unlock_track()
	train_instances.erase(train_id)
	main.remove_child(train_instance)
