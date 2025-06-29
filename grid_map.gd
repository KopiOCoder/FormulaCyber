extends GridMap

var placeholder = false

var chunk_size = 8
var load_distance = 8
var void_limit = -10

var chunks = {}
var loaded_chunks = {}
var active_chunks = {}
var cone_spawned_chunks = {}
var cone_instances = {}

var player : Node3D
var cone = load("res://cone.tscn")
var enemy_car = load("res://enemy_easy.tscn")
var enemy = false

var initial_position : Vector3
var current_position : Vector3
var last_position : Vector3
var total_distance = 0
var distance = initial_position.distance_to(current_position)
var score = int(distance)
var money: int = 0
var last_checked_score = -1


# Called when the node enters the scene tree for the first time.
func _ready():
	
	if Global.japanese == true:
		player = preload("res://japanese.tscn").instantiate()
		player.transform.origin = Vector3(880.99, 1, -2.44)  # Set the desired position
		player.rotate_y(-89.5)
		add_child(player)
	elif Global.tofu == true:
		player = preload("res://tofu.tscn").instantiate()
		player.transform.origin = Vector3(880.99, 1, -2.44)  # Set the desired position
		player.rotate_y(-89.5)
		add_child(player)
	elif Global.A_R7 == true:
		player = preload("res://A_R7.tscn").instantiate()
		player.transform.origin = Vector3(880.99, 1, -2.44)  # Set the desired position
		player.rotate_y(-89.5)
		add_child(player)
	elif Global.taxi == true:
		player = preload("res://taxi.tscn").instantiate()
		player.transform.origin = Vector3(880.99, 1, -2.44)  # Set the desired position
		player.rotate_y(-89.5)
		add_child(player)
	elif Global.lambo == true:
		player = preload("res://lambo.tscn").instantiate()
		player.transform.origin = Vector3(880.99, 1, -2.44)  # Set the desired position
		player.rotate_y(-89.5)
		add_child(player)
	elif Global.salam == true:
		player = preload("res://Salam_car.tscn").instantiate()
		player.transform.origin = Vector3(880.99, 16.326, -2.44)  # Set the desired position
		player.rotate_y(-89.5)
		add_child(player)
	elif Global.mcd == true:
		player = preload("res://MCD_car.tscn").instantiate()
		player.transform.origin = Vector3(880.99, 16.326, -2.44)  # Set the desired position
		player.rotate_y(-89.5)
		add_child(player)
	elif Global.klcc == true:
		player = preload("res://KLCC_car.tscn").instantiate()
		player.transform.origin = Vector3(880.99, 16.326, -2.44)  # Set the desired position
		player.rotate_y(-89.5)
		add_child(player)
	elif Global.mmu == true:
		player = preload("res://MMU_car.tscn").instantiate()
		player.transform.origin = Vector3(880.99, 16.326, -2.44)  # Set the desired position
		player.rotate_y(-89.5)
		add_child(player)
	else:
		player = preload("res://Raycast_car.tscn").instantiate()
		player.transform.origin = Vector3(880.99, 1, -2.44)  # Set the desired position
		player.rotate_y(89.5)
		add_child(player)

	SaveData.load_game()
	money = SaveData.money
	print("Money loaded:", money)
	$"../Game_over/Panel/NinePatchRect/VBoxContainer2/money_earned".text = "$" + str(money)
	
	initial_position = player.global_transform.origin
	last_position = player.global_transform.origin

	var unload_timer = Timer.new()
	unload_timer.wait_time = 1.0
	unload_timer.one_shot = false
	unload_timer.connect("timeout", Callable(self,"_on_UnloadTimer_timeout"))
	add_child(unload_timer)
	unload_timer.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	_process_chunk_loading()
	current_position = player.global_transform.origin
	distance = last_position.distance_to(current_position)
	total_distance += distance
	last_position = current_position
	score = round(int(total_distance))
	$"../Gui/Score".text = "Score:" + str(score)
	$"../Game_over/Panel/NinePatchRect/VBoxContainer2/Score".text = str(score)
	if player.global_transform.origin.y < void_limit:
		$"../Gui".visible = false
		current_score = score
		game_over()


func _process_chunk_loading():
	var player_chunk = Vector2(
		floor(local_to_map(player.position).x / chunk_size),
		floor(local_to_map(player.position).z / chunk_size)
	)
	var forward_offset = Vector2(1, 0)
	var newest_chunk = player_chunk + forward_offset * 5
	
	active_chunks.clear()
	
	for x in range (-load_distance, load_distance + 1):
			var chunk_pos = player_chunk + Vector2(x, 0)
			active_chunks[chunk_pos] = true
			
			if not chunks.has(chunk_pos):
				generate_chunk(chunk_pos.x, chunk_pos.y)
				loaded_chunks[chunk_pos] = true
				
			if not cone_spawned_chunks.has(newest_chunk):
				var base_pos = chunks.get(newest_chunk, null)
				if base_pos:
					generate_cone_at(newest_chunk, base_pos)
					cone_spawned_chunks[newest_chunk] = true
				else:
					print("No base position found for chunk: ", chunk_pos)
			if score % 100 == 0 and score > 0 and score != last_checked_score:
				print("score")
				last_checked_score = score
				var base_pos = chunks.get(newest_chunk, null)
				generate_car_at(newest_chunk, base_pos)
				
	for key in chunks.keys():
		if not active_chunks.has(key):
			unload_chunk(key)
			
func _on_UnloadTimer_timeout():
	for chunk_pos in loaded_chunks.keys():
		if not active_chunks.has(chunk_pos):
			unload_chunk(chunk_pos)

func unload_chunk(chunk_pos: Vector2):
	var chunk_x = chunk_pos.x
	var road_y = -2
	for x in range(chunk_x * chunk_size, (chunk_x + 1) * chunk_size):
		set_cell_item(Vector3i(x, road_y, 0), -1)
	if cone_instances.has(chunk_pos):
		for cone_node in cone_instances[chunk_pos]:
			cone_node.queue_free()
		cone_instances.erase(chunk_pos)
		
	chunks.erase(chunk_pos)
	loaded_chunks.erase(chunk_pos)
	cone_spawned_chunks.erase(chunk_pos)
		
	
func generate_chunk(chunk_x, chunk_y):
	var road_y = -2
	var base_pos = Vector3(chunk_x * chunk_size, road_y, chunk_y * chunk_size)
	for x in range(chunk_x * chunk_size, (chunk_x + 1) * chunk_size):
		set_cell_item(Vector3i(x, road_y, 0), 0)
	chunks[Vector2(chunk_x, chunk_y)] = base_pos

func generate_cone_at(chunk_pos: Vector2, base_pos: Vector3):
		var cone_gap = 2.0
		for i in range(3):
			var left_z = (i - 2) * cone_gap
			var right_z = (i + 1) * cone_gap
			var candidate_z = left_z if randf() < 0.5 else right_z
			var candidate_pos = base_pos * 2 + Vector3(0, 1, candidate_z)
			
			await get_tree().create_timer(0.01).timeout
			
			var cone_instance = cone.instantiate()
			get_tree().current_scene.add_child(cone_instance)
			cone_instance.global_transform.origin = candidate_pos
			var area_node = cone_instance.get_node("Area3D")
			if area_node:
				area_node.connect("cone_hit", Callable(self, "_on_cone_hit"))
			else:
				print("Warning: Area3D not found in cone_instance!")
			if not cone_instances.has(chunk_pos):
				cone_instances[chunk_pos] = []
				cone_instances[chunk_pos].append(cone_instance)
				
func generate_car_at(_chunk_pos: Vector2, base_pos: Vector3):
		if randf() > 0.1 and enemy == false:
			print("Car Spawned")
			var i = 3
			var left_z = (i - 2) * 2
			var right_z = (i + 1) * 2
			var candidate_z = left_z if randf() < 0.5 else right_z
			var candidate_pos = base_pos * 2 + Vector3(0, 1, candidate_z)
			var enemy_car_instance = enemy_car.instantiate() 
			enemy_car_instance.rotation_degrees.y = 90
			get_tree().current_scene.add_child(enemy_car_instance)
			enemy_car_instance.global_transform.origin = candidate_pos
			enemy = true
			await get_tree().create_timer(10).timeout
			if player.global_transform.origin > enemy_car_instance.global_transform.origin:
				total_distance += 50
				score = round(int(total_distance))
				$"../Gui/Score".text = str(score)
				enemy = false
				enemy_car_instance.queue_free()
			else:
				total_distance -= 50
				score = round(int(total_distance))
				$"../Gui/Score".text = str(score)
				enemy = false
				enemy_car_instance.queue_free()
		else:
			return
			


var current_score: int = 0

func game_over():
	var earned = int(total_distance * 0.1)
	money += earned
	SaveData.money = money
	SaveData.save_game()
	
	print("Money earned this round: $" + str(earned))
	print("Total saved money: $" + str(SaveData.money))
	
	$"../Game_over/Panel/NinePatchRect/VBoxContainer2/money_earned".text = str(earned) + "$"
	get_tree().paused = true
	$"../Game_over".visible = true
	$"../Game_over".show_game_over(score)




func _on_cone_hit():
	print("cone hit")
	total_distance -= 10
	score = round(int(total_distance))
	$"../Gui/Score".text = str(score)
	$"../Cone_hit".playing = true
