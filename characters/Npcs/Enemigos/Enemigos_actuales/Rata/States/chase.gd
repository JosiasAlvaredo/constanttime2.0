extends State_base

func start():
	controlled_node.direction=sign(controlled_node.sprite_2d.scale.x)
	controlled_node.sprite_2d.play("move")
	
func on_physics_process(delta: float) -> void:

	var enemy = controlled_node
	
	if enemy.playerUbi == null:
		state_machine.change_to("Patrol")
		return
	
	if not enemy.is_player_in_range():
		enemy.velocity.x = 0
		state_machine.change_to("Patrol")
		return
	
	enemy.velocity.y += enemy.gravity * delta
	
	var difference = enemy.playerUbi.global_position.x - enemy.global_position.x
	
	if abs(difference) > 5:
		controlled_node.direction = sign(difference)
		

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
		enemy.direction * enemy.speed*1.5,
		enemy.aceleration * delta
	)
	controlled_node.sprite_2d.scale.x=sign(enemy.velocity.x)*abs(controlled_node.sprite_2d.scale.x)
	enemy.move_and_slide()
