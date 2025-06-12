extends Control


@onready var pull_button = $MarginContainer/Pull_button
@onready var result_label = $result

func _ready():
	pull_button.pressed.connect(on_pull_pressed)

func on_pull_pressed():
	var car = GachaLogic.pull_car()
	if car:
		result_label.text = "You pulled: " + car.name + " (" + car.rarity + ")"
	else:
		result_label.text = "Pull failed. No car found!"


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Shop.tscn")
