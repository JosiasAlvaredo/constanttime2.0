extends CanvasLayer


func _on_controles_pressed() -> void:
	get_tree().change_scene_to_file("res://interface/menu/controles.tscn")

func _on_atras_pressed() -> void:
	get_tree().change_scene_to_file("res://interface/menu/menu.tscn")


func _on_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
