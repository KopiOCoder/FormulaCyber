extends Node

var money: int = 0
var score: int = 0
var session_money: int = 0

var save_path := "user://save_data.json"

func save_game():
	var save_dict = {
		"money": money,
	}
	var json = JSON.new()
	var json_string = JSON.stringify(save_dict, "\t")
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(json_string)
	file.close()
	print("Game saved. Money:", money)

func load_game():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var data = file.get_as_text()
		file.close()

		var save_dict = JSON.parse_string(data)
		if typeof(save_dict) == TYPE_DICTIONARY:
			money = save_dict.get("money", 0)
			print("Game loaded. Money:", money)
		else:
			print("Failed to parse save file: Not a dictionary.")
	else:
		print("No save file found. Starting fresh.")
