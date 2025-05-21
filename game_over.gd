extends CanvasLayer


@onready var name_input = $Panel/NinePatchRect/name_input
@onready var score_label = $Panel/NinePatchRect/VBoxContainer2/Score
@onready var leaderboard_container = $PanelContainer/leaderboard


var final_score: int = 0
var name_regex = RegEx.new()

func _ready():
	visible = false  # Hide on start
	name_regex.compile("^[A-Z0-9]{3}$")

# Call this when the game ends
func show_game_over(score: int) -> void:
	final_score = score
	score_label.text = "Your Score: %d" % score
	update_leaderboard_display()
	visible = true
	get_tree().paused = true


func update_leaderboard_display():
	for child in leaderboard_container.get_children():
		child.queue_free()
	
	var entries = Leaderboard.load_leaderboard()
	for i in range(min(entries.size(), 10)):
		var entry = entries[i]
		var label = Label.new()
		label.text = "%d. %s - %d" % [i + 1, entry["name"], entry["score"]]
		leaderboard_container.add_child(label)



func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
	


func _on_submit_button_pressed() -> void:
	var name = name_input.text.to_upper()
	if not name_regex.search(name):
		printerr("Invalid name. Use 3 letters/numbers.")
		return
	
	Leaderboard.save_score(name, final_score)
	update_leaderboard_display()
	name_input.text = ""
