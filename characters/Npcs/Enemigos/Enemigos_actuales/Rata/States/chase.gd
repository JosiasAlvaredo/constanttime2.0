extends State_base


func on_physics_process(delta: float) -> void:
	var enemy = controlled_node
	
	if enemy.playerUbi == null:
		state_machine.change_to("Idle")
		return
	
	if not enemy.is_player_in_range():
		enemy.velocity.x = 0
		state_machine.change_to("Idle")
		return
	
	enemy.velocity.y += enemy.gravity * delta
	
	var difference = enemy.playerUbi.global_position.x - enemy.global_position.x
	
	if difference > 5:
		enemy.direction = 1
	elif difference < -5:
		enemy.direction = -1
	
	enemy.update_sprite_direction()
	
	enemy.wall_ray.target_position.x = enemy.direction * 40
	enemy.floor_ray.position.x = abs(enemy.floor_ray.position.x) * enemy.direction
	
	# DEBUG
	if enemy.wall_ray.is_colliding():
		print("PARED DETECTADA")
	
	if not enemy.floor_ray.is_colliding():
		print("NO HAY SUELO")
	
	if enemy.wall_ray.is_colliding() or not enemy.floor_ray.is_colliding():
		print("CAMBIANDO A JUMP")
		state_machine.change_to("Jump")
		return
	
	enemy.velocity.x = move_toward(
		enemy.velocity.x,
		enemy.direction * enemy.speed,
		enemy.acceleration * delta
	)
	
	enemy.move_and_slide()
