extends VehicleBody3D

const MAX_STEER = 0.7

var ENGINE_POWER = 300

@export var boost_power = 200
@export var boost_fuel = 10
@export var boost_cooldown = 2
@export var boost_deplete_rate = 1
@export var boost_replenish_rate = 0.5
@onready var camera_pivot = $CameraPivot
@onready var camera_3d = $CameraPivot/Camera3D

var is_boosting = false
var cooldown_timer = 0
var look_at

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	look_at = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	steering = move_toward(steering, Input.get_axis("move_right", "move_left") * MAX_STEER, delta * 2.5)
	engine_force = Input.get_axis("move_down", "move_up") * ENGINE_POWER
	camera_pivot.global_position = camera_pivot.global_position.lerp(global_position, delta * 20)
	camera_pivot.transform = camera_pivot.transform.interpolate_with(transform, delta * 5)
	look_at = look_at.lerp(global_position + linear_velocity, delta * 5)
	camera_3d.look_at(look_at)
	
func _physics_process(delta):
	
	if Input.is_action_pressed("boost") and cooldown_timer <= 0 and boost_fuel > 0:
		is_boosting = true
		$Node3D/GPUParticles3D.emitting = true
		cooldown_timer = boost_cooldown
		ENGINE_POWER += boost_power
		boost_fuel -= boost_deplete_rate * delta
		print(engine_force)
		print($Node3D/GPUParticles3D.emitting)
	else:
		is_boosting = false
		boost_fuel = clamp(boost_fuel + boost_replenish_rate * delta, 0, 10)  
		await get_tree().create_timer(3).timeout  # 0.1 seconds delay
		$Node3D/GPUParticles3D.emitting = false
		
	if cooldown_timer > 0:
		cooldown_timer -= delta
