extends Node3D
@export var path = Path3D
@export var path_follow = PathFollow3D

func _process(delta):
	var target_position: Vector3 = Vector3(10, 0, 5)  # Replace with your actual target
	var curve = path.curve

	if curve:
		var closest_offset = curve.get_closest_offset(target_position)
