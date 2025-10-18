extends CanvasLayer


func _on_controles_pressed() -> void:
	get_tree().change_scene_to_file("res://interface/menu/controles.tscn")

func _on_atras_pressed() -> void:
	get_tree().change_scene_to_file("res://interface/menu/menu.tscn")
