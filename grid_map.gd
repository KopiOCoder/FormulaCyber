extends GridMap

var terrain_noise := FastNoiseLite.new()
var map_width = 1
var map_depth = 1
var chunk_size = 10
var chunks = {}
var loaded_chunks = {}
var active_chunks = {}
var load_distance = 10
var player
var nissan_gtr_scene = load("res://GTR_NEW.tscn")  # Load the scene
var nissan_gtr_instance = nissan_gtr_scene.instantiate()  # Create an instance
var cone = load("res://Assets/cone.tscn")
var cone_spawned_chunks = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(nissan_gtr_instance)
	player = nissan_gtr_instance
	nissan_gtr_instance.rotation_degrees.y = 90
	_process_chunk_loading()
	
	var unload_timer = Timer.new()
	unload_timer.wait_time = 1.0
	unload_timer.one_shot = false
	unload_timer.connect("timeout", Callable(self,"_on_UnloadTimer_timeout"))
	add_child(unload_timer)
	unload_timer.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	_process_chunk_loading()

func _process_chunk_loading():
	var player_chunk = Vector2(
		floor(local_to_map(player.position).x / chunk_size),
		floor(local_to_map(player.position).z / chunk_size)
	)
	active_chunks.clear()
	
	var new_chunks = {}
	
	for x in range (-load_distance, load_distance + 1):
			var chunk_pos = player_chunk + Vector2(x, 0)
			active_chunks[chunk_pos] = true
			if not chunks.has(chunk_pos):
				generate_chunk(chunk_pos.x, chunk_pos.y)
				loaded_chunks[chunk_pos] = true
			var chunk_key = str(chunk_pos.x) + "_" + str(chunk_pos.y)
			if not cone_spawned_chunks.has(chunk_key):
				generate_cone(chunk_pos.x, chunk_pos.y)
				cone_spawned_chunks[chunk_key] = true
	var chunks_to_remove = []
			
	for chunk_pos in chunks.keys():
		if not active_chunks.has(chunk_pos):
			chunks_to_remove.append(chunk_pos)
	for chunk_pos in chunks_to_remove:
		unload_chunk(chunk_pos.x, chunk_pos.y)
		chunks.erase(chunk_pos)
		var chunk_key = str(chunk_pos.x) + "_" + str(chunk_pos.y)
		cone_spawned_chunks.erase(chunk_key)
			
func _on_UnloadTimer_timeout():
	var keys = loaded_chunks.keys()
	for chunk_pos in keys:
		if not active_chunks.has(chunk_pos):
			unload_chunk(chunk_pos.x, chunk_pos.y)
			loaded_chunks.erase(chunk_pos)
			var chunk_key = str(chunk_pos.x) + "_" + str(chunk_pos.y)
			cone_spawned_chunks.erase(chunk_key)
				

func unload_chunk(chunk_x, _chunk_z):
	var road_y= -2
	for x in range(chunk_x * chunk_size, (chunk_x + 1) * chunk_size):
		set_cell_item(Vector3i(x,road_y, 0), -1)
		
	
func generate_chunk(chunk_x, chunk_y):
	var road_y = -2
	for x in range(chunk_x * chunk_size, (chunk_x + 1) * chunk_size):
		# Since you want only one layer of road, we fix Y to road_y.
		# If you need a little thickness, you could iterate over z or adjust as needed.
		set_cell_item(Vector3i(x, road_y, 0), 0)
	
	chunks[Vector2(chunk_x, chunk_y)] = true

func generate_cone(chunk_x, _chunk_y):
	var road_y = -2
	if randf() < 0.5:
		var cone_gap = 2.0
		for i in range(3):
			var left_z = (i - 2) * cone_gap
			var right_z = (i + 1) * cone_gap
			var candidate_z = left_z if randf() < 0.5 else right_z
			var candidate_pos = Vector3(
				chunk_x * chunk_size,
				road_y + 1,
				candidate_z
			)
			await get_tree().create_timer(0.01).timeout
			var cone_instance = cone.instantiate()
			get_tree().current_scene.add_child(cone_instance)
			cone_instance.global_transform.origin = candidate_pos
