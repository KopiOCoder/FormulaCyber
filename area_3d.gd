extends Area3D

signal cone_hit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	pass

func _on_body_entered(body):
	if body.name == "Nissan GTR":
		emit_signal("cone_hit")
