extends Control


func _on_racemodebutton_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/mode_selector.tscn")


func _on_garagebutton_pressed() -> void:
	pass # Replace with function body.


func _on_shopbutton_pressed() -> void:
	pass # Replace with function body.


func _on_button_pressed() -> void:
	$quit.visible = true
 

func _on_yes_pressed() -> void:
	get_tree().quit()


func _on_no_pressed() -> void:
	get_tree().reload_current_scene()


func _on_ready() -> void:
	$quit.visible = false
