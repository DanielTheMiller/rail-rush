class_name SpawnInstruction

var first_rail: Track
var second_rail: Track
var direction: Constants.Direction

func _init(first_rail: Track, second_rail: Track, direction: Constants.Direction):
	self.first_rail = first_rail
	self.second_rail = second_rail
	self.direction = direction
