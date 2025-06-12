extends Control


func _on_stage_pressed() -> void:
	get_tree().change_scene_to_file("res://difficulty_choose.tscn")


func _on_free_roam_pressed() -> void:
	get_tree().change_scene_to_file("res://main-map.tscn")


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://testing_level.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
