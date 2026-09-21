extends enemy_base



var playerUbi: Node2D = null


func _physics_process(_delta: float) -> void:

	if playerUbi == null:
		return

	var direccion := (
		playerUbi.global_position - global_position
	).normalized()

	velocity = direccion * speed

	move_and_slide()


func _on_area_2d_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
