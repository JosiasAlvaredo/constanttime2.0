extends State_base

func start() -> void:
	pass

func on_physics_process(delta: float) -> void:
	if controlled_node.player == null:
		state_machine.change_to("Patrol(exploSqueleton)")
		return

	if not is_instance_valid(controlled_node.player):
		controlled_node.player = null
		state_machine.change_to("Patrol(exploSqueleton)")
		return

	if controlled_node.player_ray.is_colliding():
		var collider = controlled_node.player_ray.get_collider()

		if collider is Player:
			controlled_node.direction = sign(
				controlled_node.player.global_position.x -
				controlled_node.global_position.x
			)

			if controlled_node.direction == 0:
				controlled_node.direction = controlled_node.last_direction

			controlled_node.last_direction = controlled_node.direction

			controlled_node.velocity.x = (
				controlled_node.direction *
				controlled_node.chase_speed
			)

			if controlled_node.wall_ray.is_colliding():
				controlled_node.velocity.x = 0
			else:
				if not controlled_node.floor_ray.is_colliding():
					controlled_node.velocity.x = 0

			return

	state_machine.change_to("Patrol(exploSqueleton)")
