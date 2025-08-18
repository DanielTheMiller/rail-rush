extends GutTest
#These unit tests will also double as an editor for these routines.
var action_class = preload("res://actions/action.gd")
var wait_action_class = preload("res://actions/wait_action.gd")

# Create freeplay routine
# Save it, open it, assert that it restores to an identical state
func test_freeplay_routine():
	# Setup
	var wait1: WaitAction = wait_action_class.new()
	var action1: Action = action_class.new()
	var routine: Array[Action] = [wait1, action1]
	const routine_name: String = "freeplay"
	# Act
	RoutineLoader.write(routine_name, routine)
	var parsedRoutine = RoutineLoader.load(routine_name)
	# Assert
	assert_eq(len(routine), len(parsedRoutine), "The number of actions in the parsed routine is incorrect")
