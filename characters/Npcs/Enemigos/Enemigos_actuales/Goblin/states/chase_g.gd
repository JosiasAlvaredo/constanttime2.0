extends State_base


func on_physics_process(delta: float) -> void:
	var enemy = controlled_node
	
	if enemy.player == null:
		state_machine.change_to("IdleG")
		return
	
	if not enemy.is_player_in_range():
		enemy.velocity.x = 0
		state_machine.change_to("IdleG")
		return
	
	var difference = enemy.player.global_position.x - enemy.global_position.x
	
	if difference > 5:
		enemy.direction = 1
	elif difference < -5:
		enemy.direction = -1
	
	enemy.wall_ray.target_position.x = enemy.direction * 30
	enemy.floor_ray.position.x = abs(enemy.floor_ray.position.x) * enemy.direction
	
	if enemy.wall_ray.is_colliding() or not enemy.floor_ray.is_colliding():
		state_machine.change_to("JumpG")
		return
	
	enemy.velocity.x = move_toward(
		enemy.velocity.x,
		enemy.direction * enemy.speed,
		enemy.acceleration * delta
	)
	
	enemy.move_and_slide()
