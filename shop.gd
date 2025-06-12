extends Control


func _on_gacha_pressed() -> void:
	get_tree().change_scene_to_file("res://Cars/Gacha_ui.tscn")


func _on_item_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://shop_collectable_menu.tscn")


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
