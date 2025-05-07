extends Node3D

@export var modules: Array[PackedScene] = []
var amount = 10
var rng = RandomNumberGenerator.new()
var offset = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for n in amount:
		SpawnModule(n * offset)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func SpawnModule(n):
	rng.randomize()
	var num = rng.randi_range(0, modules.size() - 1)
	var instance = modules[num].instantiate()
	instance.position.x = n
	add_child(instance)
