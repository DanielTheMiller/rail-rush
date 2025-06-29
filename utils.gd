extends Node

class_name UUID

const HEX_CHARS: String = "0123456789abcdef"

static func create_new() -> String:
	var hex = "0123456789abcdef"
	var rnd := RandomNumberGenerator.new()
	rnd.randomize()
	# Generate random parts
	var parts : Array = []
	parts.append(get_rand_hex_part(8, rnd))
	parts.append(get_rand_hex_part(4, rnd))
	parts.append(get_rand_hex_part(4, rnd))
	parts.append(get_rand_hex_part(4, rnd))
	parts.append(get_rand_hex_part(12, rnd))
	return "%s-%s-%s-%s-%s" % parts

static func get_rand_hex_part(part_len: int, rnd: RandomNumberGenerator) -> String:
	var part: String = ""
	for i in part_len:
		part += HEX_CHARS[rnd.randi_range(0, 15)]
	return part
