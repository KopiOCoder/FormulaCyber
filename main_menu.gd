extends Control


func _on_racemodebutton_pressed() -> void:
	get_tree().change_scene_to_file("res://mode_selector.tscn")


func _on_garagebutton_pressed() -> void:
	pass # Replace with function body.


func _on_shopbutton_pressed() -> void:
	pass # Replace with function body.


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Loading_Menu.tscn")


func _on_back_ready() -> void:
	get_viewport().gui_disable_input = false
