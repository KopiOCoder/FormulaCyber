extends Control

@onready var master_volume_slider = $Control/MarginContainer/NinePatchRect/MarginContainer/VBoxContainer/Volume/Volume/Master_vol
@onready var music_volume_slider = $Control/MarginContainer/NinePatchRect/MarginContainer/VBoxContainer/Volume/Volume/Music
@onready var sfx_volume_slider = $Control/MarginContainer/NinePatchRect/MarginContainer/VBoxContainer/Volume/Volume/SFX_vol


func _ready():
	var audio_settings = ConfigFileHandler.load_audio_settings()
	master_volume_slider.value = min(audio_settings.master_volume, 1.0) * 100
	sfx_volume_slider.value = min(audio_settings.sfx_volume, 1.0) * 100

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Loading_Menu.tscn")


func _on_configbutton_pressed() -> void:
	$Gui.visible = true


func _on_key_back_pressed() -> void:
	$Gui.visible = false




func _on_volume_slider_ready() -> void:
	$Control/MarginContainer/NinePatchRect/MarginContainer/VBoxContainer/Volume/Volume/Master_Vol.value = db_to_linear(AudioServer.get_bus_volume_db(0))


func _on_volume_slider_mouse_exited() -> void:
	release_focus()


func _on_master_vol_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileHandler.save_audio_setting("master_volume", master_volume_slider.value / 100)


func _on_music_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileHandler.save_audio_setting("music_volume", music_volume_slider.value / 100)

func _on_sfx_drag_ended(value_changed: bool) -> void:
	if value_changed:
		ConfigFileHandler.save_audio_setting("sfx_volume", sfx_volume_slider.value / 100)
