extends State_base


func start() -> void:
	var enemy = controlled_node
	
	enemy.velocity.y = enemy.jump_force


func on_physics_process(delta: float) -> void:
	var enemy = controlled_node
	
	enemy.velocity.y += enemy.gravity * delta
	
	if enemy.player != null:
		var difference = enemy.player.global_position.x - enemy.global_position.x
		
		if difference > 5:
			enemy.direction = 1
		elif difference < -5:
			enemy.direction = -1
		
		enemy.wall_ray.target_position.x = enemy.direction * 30
		enemy.floor_ray.position.x = abs(enemy.floor_ray.position.x) * enemy.direction
		
		enemy.velocity.x = move_toward(
			enemy.velocity.x,
			enemy.direction * enemy.speed,
			enemy.acceleration * delta
		)
	
	enemy.move_and_slide()
	
	if enemy.velocity.y > 0:
		state_machine.change_to("FallG")
