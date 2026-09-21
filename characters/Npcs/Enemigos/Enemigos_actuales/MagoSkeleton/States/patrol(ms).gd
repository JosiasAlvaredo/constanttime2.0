extends State_base


func start() -> void:
	var enemy = controlled_node
	
	enemy.velocity.x = enemy.direction * enemy.speed
	enemy.update_direction()


func on_physics_process(delta: float) -> void:
	var enemy = controlled_node

	enemy.velocity.x = enemy.direction * enemy.speed


	# Pared
	if enemy.front_ray.is_colliding():
		enemy.change_direction()
		return


	# Precipicio
	if not enemy.floor_ray.is_colliding():
		enemy.change_direction()
		return


	# Jugador
	if enemy.can_see_player():
		state_machine.change_to("Shoot(MS)")
