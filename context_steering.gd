extends RigidBody3D

@export var wheels : Array[RaycastWheel]
@export var max_speed = 350
@export var steer_force = 1
@export var look_ahead = 100
@export var num_rays = 16

# context array
var ray_directions = []
var interest = []
var danger = []
var axis = Vector3(1, 0 ,0)
var chosen_dir = Vector3.ZERO
var acceleration = Vector3.ZERO

func _ready() -> void:
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector3.FORWARD
		
func _get_point_velocity(point: Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_position)
	
func _physics_process(delta: float) -> void:
	set_interest()
	set_danger()
	choose_direction()
	var desired_velocity = chosen_dir.rotated(axis, 0) * max_speed
	linear_velocity = linear_velocity.lerp(desired_velocity, steer_force)
	move_and_collide(linear_velocity * delta)
	
	var grounded := false
	for wheel in wheels:
		if wheel.is_colliding():
			grounded = true
		wheel.force_raycast_update()
		_do_single_wheel_suspension(wheel)
	if grounded:
		center_of_mass = Vector3.ZERO
	else:
		center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
		center_of_mass = Vector3.DOWN * 0.5

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

func set_danger():
	var space_state = get_world_3d().direct_space_state
	var blocked_count = 0
	for i in num_rays:
		var query = PhysicsRayQueryParameters3D.create(position, position + ray_directions[i].rotated(axis, 0) * look_ahead)
		query.exclude = [self]
		var result = space_state.intersect_ray(query)
		danger[i] = 1.0 if result else 0.0
		
func set_interest():
	var path_direction = Vector3.FORWARD
	for i in num_rays:
		var d = ray_directions[i].rotated(axis, 0).dot(path_direction)
		interest[i] = max(0, d)

		
func choose_direction():
	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] = 0.0
	# Choose direction based on remaining interest
	chosen_dir = Vector3.FORWARD
	for i in num_rays:
		chosen_dir += ray_directions[i] * interest[i]
	chosen_dir = chosen_dir.normalized()
