extends Node3D

@export var total_laps: int = 1
var current_lap: int = 0
var enemy_current_lap: int = 0
var lap_start_time_ms: int = 0
var lap_times: Array = []
var race_started = false
var pass_middle = false
var enemy_pass_middle = false
var placeholder = false
var player 
var player_has_finished = false
var enemy_has_finished = false
var race_result_shown = false
@export var enemy: Node3D

var money: int = 0
@export var reward_amount: int = 100

func _ready() -> void:
	SaveData.load_game()
	get_tree().paused = false
	start_race()
	if placeholder == true:
		pass
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

func check_race_result():
	if race_result_shown:
		return
	race_result_shown = true
	
	if enemy_has_finished and not player_has_finished:
		race_started = false
		print("Rival has Won! YOU LOSE.")
		
	elif player_has_finished and not enemy_has_finished:
		race_started = false
		SaveData.money += reward_amount
		SaveData.save_game()
		print("Player wins! Cash earned: %d | Total Cash: %d" % [reward_amount, SaveData.money])
		$CanvasLayer/LapTimeLabel.text = "You Win! +$%d" % reward_amount
		$CanvasLayer/CashLabel.text = "Cash: $%d" % money
		
	elif player_has_finished and enemy_has_finished:
		print("It's a tie!")
		$CanvasLayer/LapTimeLabel.text = "Tie!"


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
		player_has_finished = true
		print("Race finished! Lap times: ", lap_times)
		check_race_result()
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
	if body.get_parent() == player and race_started and pass_middle == true:
		print("finish")
		finish_lap()
	elif body.get_parent() == enemy and race_started and enemy_pass_middle == true:
		print("enemy finish")
		finish_lap_enemy()

func _on_middle_line_body_entered(body: Node) -> void:
	print("Entered body: ", body.name)
	print("Expected player: ", player.name)
	if body.get_parent() == player and race_started:
		pass_middle = true
	return
	if body.get_parent() == enemy and race_started:
		enemy_pass_middle = true
	return
	
func finish_lap_enemy():
	if not race_started:
		return
	enemy_pass_middle = false
	enemy_current_lap += 1
	if enemy_current_lap > total_laps:
		enemy_has_finished = true
		print("Race finished! Lap times: ", lap_times)
		check_race_result()
