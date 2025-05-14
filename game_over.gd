extends CanvasLayer

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
