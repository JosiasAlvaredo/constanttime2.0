extends State_base


func on_physics_process(delta: float) -> void:
	var enemy = controlled_node
	
	enemy.velocity.y += enemy.gravity * delta
	
	if enemy.playerUbi != null:
		var difference = enemy.playerUbi.global_position.x - enemy.global_position.x
		
		if difference > 5:
			enemy.direction = 1
		elif difference < -5:
			enemy.direction = -1
		
		enemy.update_sprite_direction()
		
		enemy.velocity.x = move_toward(
			enemy.velocity.x,
			enemy.direction * enemy.speed,
			enemy.acceleration * delta
		)
	
	enemy.move_and_slide()
	
	if enemy.is_on_floor():
		if enemy.is_player_in_range():
			state_machine.change_to("Chase")
		else:
			state_machine.change_to("Idle")
