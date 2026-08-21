extends State_base

func start():
	controlled_node.velocity.x = controlled_node.direction * controlled_node.speed


func on_physics_process(delta):
	var enemy = controlled_node

	enemy.velocity.x = enemy.direction * enemy.speed

	# Pared
	if enemy.front_ray.is_colliding():
		enemy.change_direction()
		return

	# Precipicio
	if not enemy.ceiling_ray.is_colliding():
		enemy.change_direction()
		return

	# Si puede ver al jugador
	if enemy.can_see_player():
		state_machine.change_to("Shoot(Spider)")
