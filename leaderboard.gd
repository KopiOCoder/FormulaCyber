extends Control

const Save_File = "user://leaderboard.save"

var leaderboard : Array = []

@onready var  leaderboard_container = $VBoxContainer

func _ready():
	load_leaderboard()
	update_leaderboard_ui()


func add_score(name: String, time: float, score: int) -> void:
	leaderboard.append({
		"Name": name,
		"Time": time,
		"score": score
	})
	leaderboard.sort_custom(sort_leaderboard)
	save_leaderboard()
	update_leaderboard_ui()

func sort_leaderboard(a: Dictionary, b: Dictionary) -> bool:
	if a["Time"] == b["Time"]:
		return a["Score"] > b["Score"]
	return a["Time"] < b["Time"]


func save_leaderboard() -> void:
	var file = FileAccess.open(Save_File, FileAccess.WRITE)
	file.store_var(leaderboard)
	file.close()


func load_leaderboard() -> void:
	if not FileAccess.file_exists(Save_File):
		return
	var file = FileAccess.open(Save_File, FileAccess.READ)
	leaderboard = file.get_var()
	file.close()

func update_leaderboard_ui() -> void:
	leaderboard_container.clear_children()
	
	for entry in leaderboard:
		var label = Label.new()
		label.text = "%s | Time: %.2f sec | Score: %d" % [
			entry["Name"], entry["Time"], entry["Score"]
		]
		leaderboard_container.add_child(label)





func _on_button_pressed() -> void:
	var random_name = "Player" + str(randi() % 100)
	var random_time = randf_range(60.0, 120.0)
	var random_score = randi() %200
	add_score(random_name, random_time, random_score)
	
	
