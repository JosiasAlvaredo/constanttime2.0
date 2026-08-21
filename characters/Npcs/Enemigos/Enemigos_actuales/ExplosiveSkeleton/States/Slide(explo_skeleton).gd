extends State_base


func start():
	pass


func on_physics_process(delta):

	controlled_node.velocity.x = move_toward(
		controlled_node.velocity.x,
		controlled_node.direction * controlled_node.dash_speed,
		controlled_node.friction * delta
	)

	if controlled_node.front_ray.is_colliding():
		controlled_node.change_direction()
		state_machine.change_to("Idle(ExploSkeleton)")
		return

	if not controlled_node.floor_ray.is_colliding():
		controlled_node.change_direction()
		state_machine.change_to("Idle(ExploSkeleton)")
		return

	if abs(controlled_node.velocity.x) < 10:
		state_machine.change_to("Idle(ExploSkeleton)")
