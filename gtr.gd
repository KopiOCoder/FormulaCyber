extends VehicleBody3D

const MAX_STEER = 0.7

var ENGINE_POWER = 150

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
var audio_played = false
var audio_played_drift = false
const zoomed_in_fov = 90.0
const default_fov = 80.0

func _ready() -> void:
	GlobalData.set_nissan_gtr(self)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	look_at = global_position
	boost_fuel = clamp(boost_fuel, 0, 10)

func _process(delta: float) -> void:
	steering = move_toward(steering, Input.get_axis("move_right", "move_left") * MAX_STEER, delta * 2.5)
	engine_force = clamp(Input.get_axis("move_down", "move_up") * ENGINE_POWER, -150, 150)
	camera_pivot.global_position = camera_pivot.global_position.lerp(global_position, delta * 20)
	camera_pivot.transform = camera_pivot.transform.interpolate_with(transform, delta * 10)
	look_at = look_at.lerp(global_position + linear_velocity, delta * 5)
	camera_3d.look_at(look_at)
	reverse_cam.look_at(look_at)
	_check_camera_switch()


func _physics_process(delta):
	
	if Input.is_action_pressed("drift"):
		print("Drifting")
		$BL.wheel_friction_slip = 6
		$BR.wheel_friction_slip = 6
		print($BL.wheel_friction_slip)
		if audio_played_drift == false:
			$AudioStreamPlayer3D2.playing = true
			audio_played_drift = true	
		await get_tree().create_timer(1).timeout 
		
		if audio_played_drift == true:
			$AudioStreamPlayer3D2.playing = false
	
	if Input.is_action_just_released("drift"):
		print("Not Drifting")
		$BL.wheel_friction_slip = 10.5
		$BR.wheel_friction_slip = 10.5
		print($BL.wheel_friction_slip)
		audio_played_drift = false
		
	if Input.is_action_pressed("boost") and cooldown_timer <= 0 and boost_fuel > 0:
		is_boosting = true
		$Node3D/GPUParticles3D.emitting = is_boosting
		cooldown_timer = boost_cooldown
		boost_fuel -= boost_deplete_rate
		print(engine_force)
		print(boost_fuel)
		print(is_boosting)
		print($Node3D/GPUParticles3D.emitting)
		camera_3d.fov = zoomed_in_fov
		
		if audio_played == false:
			$AudioStreamPlayer3D.playing = true
			audio_played = true
			
		await get_tree().create_timer(3.5).timeout 
		
		if audio_played == true:
			$AudioStreamPlayer3D.playing = false
		
	if boost_fuel < 0:
		$Node3D/GPUParticles3D.emitting = false
		is_boosting = false
		
	if cooldown_timer > 0:
		cooldown_timer -= delta
		
	if Input.is_action_just_released("boost"):
		$Node3D/GPUParticles3D.emitting = false
		$AudioStreamPlayer3D.playing = false
		audio_played = false
		is_boosting = false
		camera_3d.fov = default_fov
	
	if is_boosting == false:
		boost_fuel += boost_replenish_rate * delta
		
func _check_camera_switch():
	if linear_velocity.dot(transform.basis.z) > -1:
		camera_3d.current = true
	else:
		reverse_cam.current = true
