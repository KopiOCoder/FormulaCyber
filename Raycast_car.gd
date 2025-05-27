extends RigidBody3D

@export var wheels : Array[RaycastWheel]
@export var acceleration := 600.0
@export var deceleration := -200.0
@export var max_speed := 20.0
@export var accel_curve : Curve
@export var max_steer_angle_deg := 30.0
@export var steer_speed := 1
var look_at
var boost_input := 1
var motor_input := 0
var turn_input := 0
var rotated = false
var steer_angle := 0.0
var audio_drift = false
var audio_boost = false
const zoomed_in_fov = 90.0
const default_fov = 80.0

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
		turn_input = 1
	elif event.is_action_released("move_left"):
		turn_input = 0
	
	if event.is_action_pressed("move_right"):
		turn_input = -1
	elif event.is_action_released("move_right"):
		turn_input = 0
	
	if event.is_action_pressed("boost"):
		max_speed = max_speed * 1.5
		acceleration = acceleration * 1.5
		$Node3D/GPUParticles3D.emitting = true
		$Node3D/GPUParticles3D2.emitting = true
		$CameraPivot/Camera3D.fov = zoomed_in_fov
		if audio_boost == false:
			$AudioStreamPlayer3D.playing = true
			audio_boost = true
	elif event.is_action_released("boost"):
		max_speed = max_speed / 1.5
		acceleration = acceleration / 1.5
		$Node3D/GPUParticles3D.emitting = false
		$Node3D/GPUParticles3D2.emitting = false
		audio_boost = false
		$CameraPivot/Camera3D.fov = default_fov
	if event.is_action_pressed("drift"):
		max_speed = max_speed / 2
		acceleration = acceleration / 2
		if audio_drift == false:
			$AudioStreamPlayer3D2.playing = true
			audio_drift = true
	elif event.is_action_released("drift"):
		max_speed = max_speed * 2
		acceleration = acceleration * 2
		audio_drift = false
		
func _physics_process(delta: float) -> void:
	var target_steer_angle = turn_input * deg_to_rad(max_steer_angle_deg)
	steer_angle = lerp(steer_angle, target_steer_angle, steer_speed * delta)
	var grounded := false
	for wheel in wheels:
		if wheel.is_colliding():
			grounded = true
		wheel.force_raycast_update()
		_do_single_wheel_suspension(wheel)
		_do_single_wheel_acceleration(wheel)
		_do_lateral_friction(wheel)
		_apply_rolling_resistance(wheel)
		if wheel.is_steering:
			wheel.steer_angle = steer_angle
	for wheel in wheels:
		if wheel.is_steering:
			wheel.rotation.y = wheel.steer_angle # Rotates the RayCast3D
	
		
	if grounded:
		center_of_mass = Vector3.ZERO
	else:
		center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
		center_of_mass = Vector3.DOWN * 0.5

func _get_point_velocity(point: Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_position)

func _do_single_wheel_acceleration(ray :RaycastWheel) -> void:
	var forward_dir := ray.global_transform.basis.z
	var vel: float = forward_dir.dot(linear_velocity)
	ray.wheel.rotate_x(vel * get_process_delta_time() * 2 * PI * ray.wheel_radius)

	if ray.is_colliding() and ray.is_motor:
		var speed_ratio: float = clamp(vel / max_speed, -1.0, 1.0)
		var accel_scale: float = accel_curve.sample_baked(abs(speed_ratio))
		var contact := ray.get_collision_point()
		var force_vector := forward_dir * acceleration * motor_input * accel_scale
		var force_pos := contact - global_position
		if motor_input:
			apply_force(force_vector, force_pos)
			
		elif abs(vel) > 0.0 :	
			force_vector = global_basis.z * deceleration * signf(vel)
			apply_force(force_vector, force_pos)
			var forward_drag: Vector3 = -forward_dir * vel * ray.longitudinal_friction
			var force_pos_new := ray.global_position - global_position
			apply_force(forward_drag, force_pos_new)
		
			
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
		
func _do_lateral_friction(ray: RaycastWheel) -> void:
	if not ray.is_colliding():
		return

	var right_dir: Vector3 = ray.global_transform.basis.x
	var wheel_velocity := _get_point_velocity(ray.global_position)
	var lateral_speed := right_dir.dot(wheel_velocity)

	if abs(lateral_speed) < 0.1:
		return # prevent jitter

	var lateral_force := -right_dir * lateral_speed * ray.lateral_friction
	var force_position := ray.global_position - global_position

	# Clamp force to avoid instability
	var max_lateral_force := 1000.0
	if lateral_force.length() > max_lateral_force:
		lateral_force = lateral_force.normalized() * max_lateral_force

	apply_force(lateral_force, force_position)
	
func _apply_rolling_resistance(wheel: RaycastWheel) -> void:
	if not wheel.is_colliding():
		return
	var velocity := _get_point_velocity(wheel.global_position)
	var resistance: Vector3 = -velocity * wheel.rolling_resistance
	apply_force(resistance, wheel.global_position - global_position)
