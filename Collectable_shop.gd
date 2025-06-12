extends Control

@onready var money_label = $Money

func _on_close_pressed() -> void:
	get_tree().change_scene_to_file("res://Shop.tscn")


func _on_ready() -> void:
	visible = true

func _process(delta):
	money_label.text = str(SaveData.money)
