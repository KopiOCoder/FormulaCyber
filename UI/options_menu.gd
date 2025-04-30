extends Control


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Loading_Menu.tscn")


func _on_configbutton_pressed() -> void:
	$Gui.visible = true


func _on_key_back_pressed() -> void:
	$Gui.visible = false




func _on_volume_slider_ready() -> void:
	$Control/MarginContainer/NinePatchRect/MarginContainer/VBoxContainer/Volume/Volume/VolumeSlider.value = db_to_linear(AudioServer.get_bus_volume_db(0))


func _on_volume_slider_mouse_exited() -> void:
	release_focus()


func _on_apply_button_pressed() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db($Control/MarginContainer/NinePatchRect/MarginContainer/VBoxContainer/Volume/Volume/VolumeSlider.value))
