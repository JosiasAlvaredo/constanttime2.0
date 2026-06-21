extends Stats


func _physics_process(delta: float) -> void:
	velocity.y+= gravity*delta
	move_and_slide()
func explosion():
	var parent=get_parent()
	var new_explosion=load("res://objets/weapons_tools/explosion.tscn").instantiate()
	new_explosion.global_position=global_position

	parent.add_child(new_explosion)
	queue_free()
	

func _on_explote_area_area_entered(area: Area2D) -> void:
	explosion()

func _on_explote_area_body_entered(body: Node2D) -> void:
	explosion()
