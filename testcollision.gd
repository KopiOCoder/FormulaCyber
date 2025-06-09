extends Area3D

@onready var mesh = $CollisionShape3D/MeshInstance3D
@onready var popup = $"../CanvasLayer/areapopup"

func _ready():
	mesh.visible = true
	await get_tree().create_timer(0.1).timeout
	body_entered.connect(handle_body_entered)
	
func handle_body_entered(body: Node3D):
	popup.popup_centered()
	await get_tree().create_timer(2.0).timeout
	queue_free()
