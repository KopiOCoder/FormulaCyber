extends Control

func _ready(): 
	$".".value = db_to_linear(AudioServer.get_bus_volume_db(0))


func _on_h_slider_mouse_exited() -> void:
	pass # Replace with function body.
	release_focus()
	
	
	
