extends Node2D

@onready var path = $Path2D
@onready var path_follow = $Path2D/PathFollow2D
var debug = false


func get_path_direction(pos):
	var offset = path.curve.get_closest_offset(pos)
	path_follow.progress = offset

	return path_follow.transform.x
