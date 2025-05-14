extends Control

func ready():
	$AnimationPlayer.play("RESET")


func _on_resume_pressed() -> void:
	resume()


func _on_button_pressed() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db($PanelContainer/MarginContainer/MarginContainer/Backplate/MarginContainer2/NinePatchRect/AudioOptions/MarginContainer3/NinePatchRect/Master_vol.value))

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("Blur")
	$"../UI".visible = true


func pause():
	get_tree().paused = true
	$AnimationPlayer.play("Blur")


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")


func _on_pause_pressed() -> void:
	pause()
	$"../UI".visible = false


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
