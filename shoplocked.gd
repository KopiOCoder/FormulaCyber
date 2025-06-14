extends Container

@onready var mmulock = $MMULockCombine
@onready var salamlock = $SalamLockCombine
@onready var mcdlock = $Row3/MCDLockCombine
@onready var klcclock = $Row3/KLCCLockCombine

var unlock_keys := {
	"mmu_unlocked": mmulockhide,
	"salam_unlocked": salamlockhide,
	"mcd_unlocked": mcdlockhide,
	"klcc_unlocked": klcclockhide
}

func _ready():
	mmulock.modulate.a = 1.0
	salamlock.modulate.a = 1.0
	mcdlock.modulate.a = 1.0
	klcclock.modulate.a = 1.0
	var json_data = load_json("res://data.json")
	if not json_data.is_empty():
		check_all_unlocks(json_data)

func load_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open JSON file at: %s" % path)
		return {}

	var content = file.get_as_text()
	var result = JSON.parse_string(content)

	if result.error != OK:
		push_error("JSON parse error: %s" % result.error_string)
		return {}

	return result.result

func check_all_unlocks(data: Dictionary) -> void:
	for key in unlock_keys.keys():
		if data.has(key) and data[key] == true:
			print("%s is unlocked! Triggering..." % key)
			unlock_keys[key].call()

func mmulockhide():
	mmulock.modulate.a = 0.0

func salamlockhide():
	salamlock.modulate.a = 0.0

func mcdlockhide():
	mcdlock.modulate.a = 0.0
	
func klcclockhide():
	klcclock.modulate.a = 0.0
