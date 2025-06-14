extends Node

var equipped_car_path: String = "res://Raycast_car.tscn"

var japanese = false
var tofu = false
var A_R7 = false
var taxi = false
var lambo = false



func save_equipped_car():
	var file = FileAccess.open("user://equipped_car.save", FileAccess.WRITE)
	if file:
		file.store_string(equipped_car_path)
		file.close()

func load_equipped_car():
	if FileAccess.file_exists("user://equipped_car.save"):
		var file = FileAccess.open("user://equipped_car.save", FileAccess.READ)
		if file:
			equipped_car_path = file.get_as_text().strip_edges()
			
func is_car_unlocked(car_path: String) -> bool:
	match car_path:
		"res://cars/data/Rx-7.tres":
			return japanese
		"res://cars/data/Tofu.tres":
			return tofu
		"res://cars/data/A_R7.tres":
			return A_R7
		"res://cars/data/taxi.tres":
			return taxi
		"res://cars/data/lambo.tres":
			return lambo
		_:
			return false
