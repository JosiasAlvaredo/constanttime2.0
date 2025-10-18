extends CanvasLayer

func _on_atras_pressed() -> void:
	get_tree().change_scene_to_file("res://interface/menu/opciones.tscn")
