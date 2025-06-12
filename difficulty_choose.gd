extends Control


func _on_easy_pressed() -> void:
	get_tree().change_scene_to_file("res://Sepang_easy.tscn")


func _on_hard_pressed() -> void:
	get_tree().change_scene_to_file("res://Sepang_hard.tscn")
