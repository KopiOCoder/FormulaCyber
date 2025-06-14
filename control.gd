extends Control


@onready var pull_button = $MarginContainer/Pull_button
@onready var result_label = $result
@onready var money_label = $Money

func _ready():
	SaveData.load_game()
	update_money_display()
	pull_button.pressed.connect(on_pull_pressed)

func  update_money_display():
	money_label.text = "Money: $" + str(SaveData.money)

func get_color_for_rarity(rarity: String) -> Color:
	match rarity:
		"Common": return Color.WHITE
		"Rare": return Color.CYAN
		"Epic": return Color.MEDIUM_PURPLE
		"Legendary": return Color.GOLD
		_: return Color.GRAY


func on_pull_pressed():
	if SaveData.money < 1000:
		result_label.text = "Not enough money to pull!"
		result_label.modulate = Color.RED
		return
	SaveData.money -= 1000
	SaveData.save_game()
	update_money_display()
 
	

	var car = GachaLogic.pull_car()
	if car:
		result_label.text = "You pulled: " + car.name + " (" + car.rarity + ")"
		result_label.modulate = get_color_for_rarity(car.rarity)
	else:
		result_label.text = "Pull failed. No car found!"
		result_label.modulate = Color.RED


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Shop.tscn")
