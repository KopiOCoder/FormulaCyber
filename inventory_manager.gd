extends Node


class_name InventoryManager

# List of owned CarData resources
var owned_cars: Array[Resource] = []

func _ready():
	load_inventory()

# Add a new car to inventory and save it
func add_to_inventory(car: Resource) -> void:
	if car and not owned_cars.has(car):
		owned_cars.append(car)
		save_inventory()

# Save owned cars to disk as JSON array of resource paths
func save_inventory() -> void:
	var data: Array = []
	for car in owned_cars:
		data.append(car.resource_path)

	var file = FileAccess.open("user://inventory.save", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
	else:
		push_error("Failed to open inventory file for writing.")

# Load saved cars from disk into owned_cars
func load_inventory() -> void:
	if not FileAccess.file_exists("user://inventory.save"):
		return

	var file = FileAccess.open("user://inventory.save", FileAccess.READ)
	if not file:
		push_error("Failed to open inventory file for reading.")
		return

	var json_text = file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_text)
	if typeof(data) != TYPE_ARRAY:
		push_error("Failed to parse inventory JSON or invalid format.")
		return
		
	owned_cars.clear()
	for path in data:
		var car = load(path)
		if car:
			owned_cars.append(car)
