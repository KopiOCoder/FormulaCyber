extends Control


func _on_racemodebutton_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/mode_selector.tscn")


func _on_garagebutton_pressed() -> void:
	pass # Replace with function body.


func _on_shopbutton_pressed() -> void:
	get_tree().change_scene_to_file("res://Shop.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Loading_Menu.tscn")
 
