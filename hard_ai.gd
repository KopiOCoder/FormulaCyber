extends PathFollow3D

@export var speed: float = 30

func _physics_process(delta):
	progress += speed * delta

	# Update rigidbody to match PathFollow3D's position and orientation
	var body = $Enemy
	var target_transform = global_transform
	target_transform.basis *= Basis(Vector3.UP, deg_to_rad(180)) # Rotate 180° on Y axis
	body.global_transform = target_transform
