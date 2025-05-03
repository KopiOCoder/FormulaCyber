extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var nissan_gtr_scene = load("res://GTR_NEW.tscn")  # Load the scene
	var nissan_gtr_instance = nissan_gtr_scene.instantiate()  # Create an instance
	add_child(nissan_gtr_instance)  # Add it to endless_mode


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
