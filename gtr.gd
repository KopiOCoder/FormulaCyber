extends VehicleBody3D

const MAX_STEER = 0.7

var ENGINE_POWER = 300

@export var boost_power = 200
@export var boost_fuel = 10
@export var boost_cooldown = 3.5
@export var boost_deplete_rate = 1.5
@export var boost_replenish_rate = 0.5
@onready var camera_pivot = $CameraPivot
@onready var camera_3d = $CameraPivot/Camera3D
@onready var reverse_cam = $CameraPivot/ReverseCam
var is_boosting = false
var cooldown_timer = 0
var look_at
var initial_position : Vector3
var current_position : Vector3
var last_position : Vector3
var total_distance = 0
var distance = initial_position.distance_to(current_position)
var score = int(distance)
var audio_played = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	look_at = global_position
	initial_position = global_transform.origin
	last_position = global_transform.origin
	boost_fuel = clamp(boost_fuel, 0, 10)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	steering = move_toward(steering, Input.get_axis("move_right", "move_left") * MAX_STEER, delta * 2.5)
	engine_force = clamp(Input.get_axis("move_down", "move_up") * ENGINE_POWER, -600, 600)
	camera_pivot.global_position = camera_pivot.global_position.lerp(global_position, delta * 20)
	camera_pivot.transform = camera_pivot.transform.interpolate_with(transform, delta * 10)
	look_at = look_at.lerp(global_position + linear_velocity, delta * 5)
	camera_3d.look_at(look_at)
	reverse_cam.look_at(look_at)
	_check_camera_switch()
	current_position = global_transform.origin
	distance = last_position.distance_to(current_position)
	total_distance += distance
	last_position = current_position
	score = int(total_distance)
	$"../Gui/Score".text = str(score)
	
func _physics_process(delta):
	
	if Input.is_action_pressed("boost") and cooldown_timer <= 0 and boost_fuel > 0:
		is_boosting = true
		$Node3D/GPUParticles3D.emitting = is_boosting
		cooldown_timer = boost_cooldown
		ENGINE_POWER += boost_power
		boost_fuel -= boost_deplete_rate
		print(engine_force)
		print(boost_fuel)
		print(is_boosting)
		print($Node3D/GPUParticles3D.emitting)
		
		
		if audio_played == false:
			$AudioStreamPlayer3D.playing = true
			audio_played = true
			
		await get_tree().create_timer(3.5).timeout 
		
		if audio_played == true:
			$AudioStreamPlayer3D.playing = false
		
	if boost_fuel < 0:
		$Node3D/GPUParticles3D.emitting = false
		
	if cooldown_timer > 0:
		cooldown_timer -= delta
		
	if Input.is_action_just_released("boost"):
		$Node3D/GPUParticles3D.emitting = false
		$AudioStreamPlayer3D.playing = false
		audio_played = false
		is_boosting = false
	
	if is_boosting == false:
		boost_fuel += boost_replenish_rate * delta
		
func _check_camera_switch():
	if linear_velocity.dot(transform.basis.z) > -1:
		camera_3d.current = true
	else:
		reverse_cam.current = true
