extends RigidBody3D


func _on_body_entered(body):
	if body.name == "Car":
		apply_impulse(Vector3(0, 10, 0), Vector3.ZERO)
