extends State_base


func on_physics_process(delta: float) -> void:
	var enemy = controlled_node
	
	enemy.velocity.y += enemy.gravity * delta
	
	if enemy.player != null:
		var difference = enemy.player.global_position.x - enemy.global_position.x
		
		if difference > 5:
			enemy.direction = 1
		elif difference < -5:
			enemy.direction = -1
		
		enemy.velocity.x = move_toward(
			enemy.velocity.x,
			enemy.direction * enemy.speed,
			enemy.acceleration * delta
		)
	
	enemy.move_and_slide()
	
	if enemy.is_on_floor():
		if enemy.is_player_in_range():
			state_machine.change_to("ChaseG")
		else:
			state_machine.change_to("IdleG")
