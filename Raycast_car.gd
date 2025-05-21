extends RigidBody3D

@export var wheels : Array[RaycastWheel]
@export var acceleration := 600.0
@export var deceleration := -200.0
@export var max_speed := 20.0
@export var accel_curve : Curve
@export var lateral_friction_factor := 200.0 
@export var angular_damp_factor := 200.0
@onready var camera_pivot = $CameraPivot
@onready var camera_3d = $CameraPivot/Camera3D
@onready var reverse_cam = $CameraPivot/ReverseCam
var look_at
var motor_input := 0
var turn_input := 0
var rotated = false

func _ready() -> void:
	look_at = global_position

func _process(delta: float) -> void:
	camera_pivot.global_position = camera_pivot.global_position.lerp(global_position, delta * 20)
	camera_pivot.transform = camera_pivot.transform.interpolate_with(transform, delta)
	look_at = look_at.lerp(global_position + linear_velocity, delta * 5)
	camera_3d.look_at(look_at)
	reverse_cam.look_at(look_at)
	_check_camera_switch()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("accelerate"):
		motor_input = 1
	elif event.is_action_released("accelerate"):
		motor_input = 0
		print(motor_input)
		
	if event.is_action_pressed("decelerate"):
		motor_input = -1
	elif event.is_action_released("decelerate"):
		motor_input = 0
	
	if event.is_action_pressed("move_left"):
		turn_input = -1
	elif event.is_action_released("move_left"):
		turn_input = 0
	
	if event.is_action_pressed("move_right"):
		turn_input = 1
	elif event.is_action_released("move_right"):
		turn_input = 0
		
func _physics_process(_delta: float) -> void:
	var grounded := false
	for wheel in wheels:
		if wheel.is_colliding():
			grounded = true
		wheel.force_raycast_update()
		_do_single_wheel_suspension(wheel)
		_do_single_wheel_acceleration(wheel)

	
	# --- Angular damping (counter torque) ---
	# When no steering input exists (or even when there is, if you wish),
	# apply a torque impulse opposite to the car's angular velocity.
	if turn_input == 0:
		var sideways_dir: Vector3 = global_transform.basis.x
		var sideways_speed: float = linear_velocity.dot(sideways_dir)
		var lateral_counterforce: Vector3 = -sideways_dir * sideways_speed * lateral_friction_factor
		apply_force(lateral_counterforce, Vector3.ZERO)
		var counter_torque: Vector3 = -angular_velocity * angular_damp_factor
		apply_torque_impulse(counter_torque * _delta)

	if grounded:
		center_of_mass = Vector3.ZERO
	else:
		center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
		center_of_mass = Vector3.DOWN * 0.5

func _get_point_velocity(point: Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_position)

func _do_single_wheel_acceleration(ray :RaycastWheel) -> void:
	var forward_dir := ray.global_basis.z
	var vel := forward_dir.dot(linear_velocity)
	
	ray.wheel.rotate_x(vel * get_process_delta_time() * 2 * PI * ray.wheel_radius)
	if ray.is_colliding() and ray.is_motor:
		var speed_ratio := vel / max_speed
		var ac:= accel_curve.sample_baked(speed_ratio)
		var contact := ray.wheel.global_position
		var force_vector := forward_dir * acceleration * motor_input * ac
		var lateral_offset := Vector3.RIGHT * turn_input * 0.5
		var force_pos := contact - global_position + lateral_offset
		if motor_input:
			apply_force(force_vector, force_pos)
			
		elif abs(vel) > 0.0 :	
			force_vector = global_basis.z * deceleration * signf(vel)
			apply_force(force_vector, force_pos)
		
			
func _do_single_wheel_suspension(ray: RaycastWheel) -> void:
	if ray.is_colliding():
		ray.target_position.y = -(ray.rest_dist + ray.wheel_radius + ray.over_extend)
		var contact := ray.get_collision_point()
		var spring_up_dir := ray.global_transform.basis.y
		var spring_len := ray.global_position.distance_to(contact) - ray.wheel_radius
		var off_set := ray.rest_dist - spring_len

		ray.wheel.position.y = - spring_len

		var spring_force := ray.spring_str * off_set
		var world_vel := _get_point_velocity(contact)
		var relative_vel := spring_up_dir.dot(world_vel)
		var spring_damp_force := ray.spring_dmp * relative_vel
		var force_vector := (spring_force - spring_damp_force) * spring_up_dir
		
		contact = ray.wheel.global_position
		var force_pos_offset := contact - global_position
		apply_force(force_vector, force_pos_offset)

func _check_camera_switch():
	if linear_velocity.dot(transform.basis.z) > -1:
		camera_3d.current = true
	else:
		reverse_cam.current = true
