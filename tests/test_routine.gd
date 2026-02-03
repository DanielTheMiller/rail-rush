extends GutTest
#These unit tests will also double as an editor for these routines.
var action_class = preload("res://actions/Action.cs")
var wait_action_class = preload("res://actions/WaitAction.cs")
var train_spawn_action_class = preload("res://actions/TrainSpawnAction.cs")
var coin_spawn_action_class = preload("res://actions/TrainSpawnAction.cs")
var routine_loader_class = preload("res://helpers/RoutineLoader.cs")

# Create freeplay routine
# Save it, open it, assert that it restores to an identical state
func test_freeplay_routine():
	# Setup
	var routine_loader = routine_loader_class.new()
	var wait1 = wait_action_class.new()
	var trainspawn1 = train_spawn_action_class.new()
	var coinspawn1 = coin_spawn_action_class.new()
	var routine: Array = [wait1, trainspawn1, coinspawn1]
	var routine_name: String = "freeplay"
	wait_action_class.Howdy()
	# Act
	routine_loader.Test1()
	routine_loader.Test2("Test!!")
	routine_loader.Write(routine_name, routine)
	var parsedRoutine: Array = routine_loader.Load(routine_name)
	#var parsedRoutine = routine_loader.Load(routine_name)
	# Assert
	assert_not_null(parsedRoutine, "Could not load recently written routine")
	if type_string(typeof(parsedRoutine)) != "Nil":
		assert_eq(len(routine), len(parsedRoutine), "The number of actions in the parsed routine is incorrect")
		for action_i in len(routine):
			var original_action = routine[action_i]
			var restored_action = parsedRoutine[action_i]
			print("Original at %s is %s; Restored is %s" % [action_i, original_action, restored_action.get_class()])
			assert_eq(original_action.get_class(), restored_action.get_class(), "Type mismatch between original and restored action!")
			
