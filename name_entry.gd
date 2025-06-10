extends HBoxContainer


@export var valid_chars := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
var current_chars := ["A", "A", "A"]
var current_index := 0  # which char (0-2) is selected

func _ready():
	update_display()
	set_process_input(true)

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_LEFT:
				current_index = max(current_index - 1, 0)
				highlight_selected()
			KEY_RIGHT:
				current_index = min(current_index + 1, 2)
				highlight_selected()
			KEY_UP:
				increment_char(1)
			KEY_DOWN:
				increment_char(-1)

func increment_char(amount):
	var current_char = current_chars[current_index]
	var idx = valid_chars.find(current_char)
	if idx == -1: idx = 0
	idx = (idx + amount) % valid_chars.length()
	current_chars[current_index] = valid_chars[idx]
	update_display()

func update_display():
	for i in range(3):
		var label = get_node("Char" + str(i + 1)) as Label
		label.text = current_chars[i]
		label.add_theme_color_override("font_color", Color.WHITE)
		if i == current_index:
			label.add_theme_color_override("font_color", Color.YELLOW)

func highlight_selected():
	update_display()

func get_final_name():
	return "".join(current_chars)
