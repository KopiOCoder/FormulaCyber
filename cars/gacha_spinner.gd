extends Control

signal finished_spinning(car: CarData)

var car_list: Array[CarData]
var final_car: CarData
var is_spinning := false

@onready var label: Label = $CarNameLabel

func start_spin(_car_list: Array[CarData], _final_car: CarData):
	car_list = _car_list
	final_car = _final_car
	is_spinning = true
	show()

	spin_animation()

func spin_animation() -> void:
	var spin_time = 2.5
	var elapsed = 0.0
	var delay = 0.05

	while elapsed < spin_time:
		var current = car_list.pick_random()
		label.text = current.name
		await get_tree().create_timer(delay).timeout
		elapsed += delay
		delay *= 1.08  # Slow down

	label.text = final_car.name
	is_spinning = false

	await get_tree().create_timer(1.0).timeout
	emit_signal("finished_spinning", final_car)
	hide()
