extends Control


func _on_play_pressed() -> void:
	pass # Replace with function body.
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_options_pressed() -> void:
	pass # Replace with function body.
	get_tree().change_scene_to_file("res://settings_menu.tscn")


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://Info.tscn")


func _on_button_pressed() -> void:
	get_tree().quit()
	
