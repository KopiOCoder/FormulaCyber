extends Control


func _on_play_pressed() -> void:
	pass # Replace with function body.
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")


func _on_options_pressed() -> void:
	pass # Replace with function body.
	get_tree().change_scene_to_file("res://UI/options_menu.tscn")


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Info.tscn")



func _on_yes_pressed() -> void:
	get_tree().quit()


func _on_no_pressed() -> void:
	get_tree().reload_current_scene()


func _on_ready() -> void:
	$quit.visible = false


func _on_button_pressed() -> void:
	$quit.visible = true
