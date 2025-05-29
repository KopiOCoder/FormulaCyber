extends Node
class_name GachaManager


const CAR_DATA_PATH = "res://cars/data/"


var rarity_chances = {
	"common": 0.6,
	"rare": 0.3,
	"epic": 0.09,
	"legendary": 0.01
}


var rarity_order = ["common", "rare", "epic", "legendary"]


var car_database: Array[CarData] = []

func _ready():
	load_car_database()

func load_car_database():
	car_database.clear()

	var dir = DirAccess.open(CAR_DATA_PATH)
	if dir == null:
		push_error("Failed to open directory: %s" % CAR_DATA_PATH)
		return

	for file_name in dir.get_files():
		if file_name.ends_with(".tres"):
			var car = load(CAR_DATA_PATH + file_name)
			if car is CarData:
				print_debug("Loaded car: %s, rarity: %s" % [car.name, car.rarity])
				car_database.append(car)
			else:
				push_warning("File is not a valid CarData resource: %s" % file_name)

func get_random_rarity() -> String:
	var roll = randf()
	var total = 0.0
	for rarity in rarity_order:
		total += rarity_chances.get(rarity, 0.0)
		if roll <= total:
			return rarity
	return "common"  # fallback

func pull_car() -> CarData:
	var rarity = get_random_rarity()
	print_debug("Rolled rarity: %s" % rarity)

	for c in car_database:
		print_debug("Available car: %s with rarity: %s" % [c.name, c.rarity])

	var candidates = car_database.filter(func(c): return c.rarity == rarity)

	if candidates.is_empty():
		push_warning("No cars found for rarity: %s" % rarity)
		return null

	var chosen = candidates.pick_random()
	print_debug("Chosen car: %s" % chosen.name)
	Inventory.add_to_inventory(chosen)
	return chosen
