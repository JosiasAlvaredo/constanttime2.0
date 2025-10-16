extends CanvasLayer

func _physics_process(_delta):
		if Input.is_action_just_pressed("Pausa"):
			get_tree().paused = not get_tree().paused
			$ColorRect.visible = not $ColorRect.visible
			$regresar.visible = not $regresar.visible
			$menu.visible =not $menu.visible


func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://interface/menu/menu.tscn")

func resume():
	get_tree().paused = false
	$ColorRect.visible = not $ColorRect.visible
	$regresar.visible = not $regresar.visible
	$menu.visible =not $menu.visible

func _on_regresar_pressed() -> void:
	resume()
