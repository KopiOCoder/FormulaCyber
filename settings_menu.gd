extends Control


func _on_back_pressed() -> void:
	pass # Replace with function body.
	get_tree().change_scene_to_file("res://main_menu.tscn")



func _on_resume_pressed() -> void:
	pass # Replace with function body.
	get_tree().change_scene_to_file("res://testing_level.tscn")
