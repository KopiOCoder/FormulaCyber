extends RayCast3D
class_name RaycastWheel

@export var spring_str := 100.0
@export var spring_dmp := 2.0
@export var rest_dist := 0.5
@export var over_extend := 0.0
@export var wheel_radius := 0.4
@export var is_motor := false

@onready var wheel: Node3D = get_child(0)
@onready var wheel_mesh: Node3D = $"../FR/Wheel".get_child(0)
