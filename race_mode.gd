extends Node3D

@export var total_laps: int = 3
var current_lap: int = 0
var enemy_current_lap: int = 0
var lap_start_time_ms: int = 0
var lap_times: Array = []
var race_started = false
var pass_middle = false
var enemy_pass_middle = false
var player 
@export var enemy: Node3D


func _ready() -> void:
	get_tree().paused = false
	start_race()
	if Global.japanese == true:
		player = preload("res://japanese.tscn").instantiate()
		player.transform.origin = Vector3(880.99, 16.326, -2.44)  # Set the desired position
		player.rotate_y(-89.5)
		add_child(player)
	elif Global.tofu == true:
		player = preload("res://tofu.tscn").instantiate()
		player.transform.origin = Vector3(880.99, 16.326, -2.44)  # Set the desired position
		player.rotate_y(-89.5)
		add_child(player)
	elif Global.A_R7 == true:
		player = preload("res://A_R7.tscn").instantiate()
		player.transform.origin = Vector3(880.99, 16.326, -2.44)  # Set the desired position
		player.rotate_y(-89.5)
		add_child(player)
	elif Global.taxi == true:
		player = preload("res://taxi.tscn").instantiate()
		player.transform.origin = Vector3(880.99, 16.326, -2.44)  # Set the desired position
		player.rotate_y(-89.5)
		add_child(player)
	elif Global.lambo == true:
		player = preload("res://lambo.tscn").instantiate()
		player.transform.origin = Vector3(880.99, 16.326, -2.44)  # Set the desired position
		player.rotate_y(-89.5)
		add_child(player)
	else:
		player = preload("res://Raycast_car.tscn").instantiate()
		player.transform.origin = Vector3(880.99, 16.326, -2.44)  # Set the desired position
		player.rotate_y(-89.5)
		add_child(player)
	
func start_race():
	current_lap = 1
	enemy_current_lap = 1
	lap_start_time_ms = Time.get_ticks_msec()
	race_started = true
	lap_times.clear()

func finish_lap():
	if not race_started:
		return

	var now_ms = Time.get_ticks_msec()
	var lap_time_ms = now_ms - lap_start_time_ms
	lap_times.append(lap_time_ms / 1000.0)  # store lap time in seconds
	pass_middle = false
	print("Lap %d time: %.2f seconds" % [current_lap, lap_times[-1]])

	current_lap += 1
	lap_start_time_ms = now_ms

	if current_lap > total_laps:
		race_started = false
		print("Race finished! Lap times: ", lap_times)
		# Handle end of race logic here

func _process(_delta):
	if race_started:
		var now_ms = Time.get_ticks_msec()
		var current_lap_time = (now_ms - lap_start_time_ms) / 1000.0
		var laps_left = total_laps - current_lap + 1
		var enemy_laps_left = total_laps - enemy_current_lap + 1

		$CanvasLayer/LapTimeLabel.text = "Lap Time: %.2fs" % current_lap_time
		$CanvasLayer/LapsLeftLabel.text = "Laps Left: %d" % laps_left
		$CanvasLayer/EnemyLapsLeftLabel.text = "Enemy Laps Left: %d" % enemy_laps_left
	else:
		$CanvasLayer/LapTimeLabel.text = "Race not started"
		$CanvasLayer/LapsLeftLabel.text = ""
		$CanvasLayer/EnemyLapsLeftLabel.text = ""


	
func _on_finish_line_body_entered(body: Node) -> void:
	print("Entered body: ", body.name)
	print("Expected player: ", player.name)
	print(pass_middle)
	if body == player and race_started and pass_middle == true:
		print("finish")
		finish_lap()
	if body.get_parent() == enemy and race_started and enemy_pass_middle == true:
		print("enemy finish")
		finish_lap_enemy()

func _on_middle_line_body_entered(body: Node) -> void:
	print("Entered body: ", body.name)
	print("Expected player: ", player.name)
	if body == player and race_started:
		pass_middle = true
	elif body.get_parent() == enemy and race_started:
		enemy_pass_middle = true
		print(enemy_pass_middle)

	
func finish_lap_enemy():
	if not race_started:
		return
	enemy_pass_middle = false
	enemy_current_lap += 1
	if enemy_current_lap > total_laps:
		race_started = false
		print("Race finished! Lap times: ", lap_times)
