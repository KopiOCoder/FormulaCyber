extends TextureRect

@export var minimap_size: Vector2 = Vector2(512, 512)
@export var world_top_left_node: Node3D
@export var world_bottom_right_node: Node3D
@export var player: Node3D

@onready var player_icon = $Player_icon

func _process(_delta):
	var top_left = world_top_left_node.global_position
	var bottom_right = world_bottom_right_node.global_position
	var player_pos = player.global_position

	var world_size = Vector2(
		bottom_right.x - top_left.x,
		bottom_right.z - top_left.z
	)

	if world_size.x == 0 or world_size.y == 0:
		return
	
	var rel_pos = Vector2(
		player_pos.x - top_left.x,
		player_pos.z - top_left.z
	)

	var normalized = rel_pos / world_size
	var minimap_pos = normalized * minimap_size
	
	var zoom_factor = 3.0

	# The "origin" to zoom around is the initial minimap_pos (keep it steady)
	# Any offset from this origin is scaled
	# In this case, player_icon.position = origin + (current_offset * zoom_factor)
	# Since player_pos == origin, offset is zero, so the dot stays correctly positioned.

	# But since the player dot is the only thing moving, just apply zoom_factor directly:
	player_icon.position = minimap_pos * zoom_factor
	
	# Clamp so the dot stays inside the minimap rect
	player_icon.position = player_icon.position.clamp(Vector2.ZERO, minimap_size)
