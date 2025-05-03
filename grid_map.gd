extends GridMap

var terrain_noise := FastNoiseLite.new()
var map_width = 10
var map_depth = 1
var chunk_size = 10.0
var chunks = {}
var load_distance = 3
var player
var nissan_gtr_scene = load("res://GTR_NEW.tscn")  # Load the scene
var nissan_gtr_instance = nissan_gtr_scene.instantiate()  # Create an instance

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(nissan_gtr_instance)
	player = nissan_gtr_instance
	nissan_gtr_instance.rotation_degrees.y = 90
	_process_chunk_loading()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	_process_chunk_loading()

func _process_chunk_loading():
	var player_chunk = Vector2(
		floor(local_to_map(player.position).x / chunk_size),
		floor(local_to_map(player.position).z / chunk_size)
	)
	
	var new_chunks = {}
	
	for x in range (-load_distance, load_distance + 1):
			var chunk_pos = player_chunk + Vector2(x, 0)
			new_chunks[chunk_pos] = true
			if not chunks.has(chunk_pos):
				generate_chunk(chunk_pos.x, chunk_pos.y)
	
	for chunk_pos in chunks.keys():
		if not new_chunks.has(chunk_pos):
			unload_chunk(chunk_pos.x, chunk_pos.y)
			
	chunks = new_chunks

func unload_chunk(chunk_x, chunk_z):
	var half_width = chunk_size / 2.0
	var half_depth = chunk_size / 2.0
	
	for x in range(chunk_x * chunk_size - half_width, chunk_x * chunk_size + half_width):
		for z in range(chunk_z * chunk_size - half_depth, chunk_z * chunk_size + half_depth):
			for y in range(0, 1):
				set_cell_item(Vector3i(x, y, z), -1) # -1 unloads the cell
	
func generate_chunk(chunk_x, chunk_y):
	var road_y = -2
	for x in range(chunk_x * chunk_size, (chunk_x + 1) * chunk_size):
		# Since you want only one layer of road, we fix Y to road_y.
		# If you need a little thickness, you could iterate over z or adjust as needed.
		set_cell_item(Vector3i(x, road_y, 0), 0)
	
	chunks[Vector2(chunk_x, chunk_y)] = true
