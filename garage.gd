extends Control


@export var all_car: Array[Resource]
@onready var car_grid = $CanvasLayer/GridContainer
@onready var equip_button = $CanvasLayer/equip_button
@onready var car_display = $car_display

var selected_car: Resource = null

func _ready():
	if all_car.size() == 0:
		print("⚠️ 'all_car' array is empty! Set it in the Inspector.")
	else:
		print("Found", all_car.size(), "cars.")
		
	populate_car_buttons()
	equip_button.disabled = true
	
	for car in all_car:
		print(">>", car.name, car.icon, car.resource_path)


	
	for car_data in all_car:
		print("Adding:", car_data.name, "Icon:", car_data.icon)
		var btn = TextureButton.new()
		btn.texture_normal = car_data.icon
		btn.tooltip_text = car_data.name
		btn.custom_minimum_size = Vector2(96, 96)  # Set button/icon size
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		btn.connect("pressed", Callable(self, "_on_car_selected").bind(car_data))





func populate_car_buttons():
	for child in car_grid.get_children():
		child.queue_free()
	
	for car_data in all_car:
		var btn = TextureButton.new()
		btn.texture_normal = car_data.icon
		btn.tooltip_text = car_data.name
		btn.connect("pressed", Callable(self, "_on_car_selected").bind(car_data))
		
		if not Global.is_car_unlocked(car_data.resource_path):
			btn.modulate = Color(0.5, 0.5, 0.5)
			btn.disabled = true
			
		car_grid.add_child(btn)

func _on_car_selected(car_data: CarData):
	selected_car = car_data
	car_display.texture = car_data.icon
	
	equip_button.disabled = not Global.is_car_unlocked(car_data.resource_path)
	


func _on_equip_pressed(car_data: CarData):
	
	if selected_car == null:
		return
	
	if not Global.is_car_unlocked(selected_car.resource_path):
		print("You don't own this car.")
		return

	Global.equipped_car_path = selected_car.resource_path
	Global.save_equipped_car()
	print("Equipped:", selected_car.name)
