extends Area3D

@onready var mesh = $mcdcollision/mcdmesh
@onready var popup = $"../CanvasLayer/areapopup"

var variable_name = "mcd_unlocked"

func _ready():
	mesh.visible = true
	await get_tree().create_timer(0.1).timeout
	body_entered.connect(handle_body_entered)
	
func handle_body_entered(body: Node3D):
	popup.popup_centered()
	update_json(variable_name, true)
	await get_tree().create_timer(2.0).timeout
	queue_free()

func update_json(key, value):
	var file = FileAccess.open("res://area_unlocked.json", FileAccess.READ)
	var json_data = JSON.parse_string(file.get_as_text())
	file.close()

	json_data[key] = value

	file = FileAccess.open("res://area_unlocked.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(json_data, "\t"))
	file.close()
