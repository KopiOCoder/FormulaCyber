extends Control


func _on_stage_pressed() -> void:
	pass # Replace with function body.


func _on_free_roam_pressed() -> void:
	get_tree().change_scene_to_file("res://main-map.tscn")


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://testing_level.tscn")
