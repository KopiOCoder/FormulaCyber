extends Node3D
var initial_position : Vector3
var current_position : Vector3
var last_position : Vector3
var total_distance = 0
var distance = initial_position.distance_to(current_position)
var score = int(distance)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	initial_position = $"Nissan GTR".global_transform.origin
	last_position = $"Nissan GTR".global_transform.origin


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_position = $"Nissan GTR".global_transform.origin
	distance = last_position.distance_to(current_position)
	total_distance += distance
	last_position = current_position
	score = int(total_distance)
	$Gui/Score.text = str(score)
