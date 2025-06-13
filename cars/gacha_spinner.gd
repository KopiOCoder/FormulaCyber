extends Control

signal finished_spinning(car: CarData)

var car_list: Array[CarData]
var final_car: CarData
var is_spinning := false

@onready var label: Label = $CarNameLabel

func start_spin(_car_list: Array[CarData], _final_car: CarData):
	if SaveData.money < 1000:
		label.text = "Not enough Money!"
		label.modulate = Color.RED
		await get_tree().create_timer(2.0).timeout
		hide()
		return
	SaveData.money -= 1000
	SaveData.save_game()
	
	car_list = _car_list
	final_car = _final_car
	is_spinning = true
	show()

	spin_animation()

func get_color_for_rarity(rarity: String) -> Color:
	match rarity:
		"Common":
			return Color.WHITE
		"Rare":
			return Color.CYAN
		"Epic":
			return Color.MEDIUM_PURPLE
		"Legendary":
			return Color.GOLD
		_:
			return Color.GRAY


func spin_animation() -> void:
	var spin_time = 2.5
	var elapsed = 0.0
	var delay = 0.05

	while elapsed < spin_time:
		var current = car_list.pick_random()
		label.text = final_car.name
		label.modulate = get_color_for_rarity(final_car.rarity)
		await get_tree().create_timer(delay).timeout
		elapsed += delay
		delay *= 1.08  # Slow down

	label.text = final_car.name
	is_spinning = false

	await get_tree().create_timer(1.0).timeout
	emit_signal("finished_spinning", final_car)
	hide()
