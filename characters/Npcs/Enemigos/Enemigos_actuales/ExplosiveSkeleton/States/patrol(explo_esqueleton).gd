extends State_base

func start() -> void:
	pass

func on_physics_process(delta: float) -> void:
	if controlled_node.player == null:
		controlled_node.player = get_tree().get_first_node_in_group("player")

	controlled_node.velocity.x = controlled_node.direction * controlled_node.patrol_speed

	if controlled_node.wall_ray.is_colliding():
		controlled_node.direction *= -1
		return

	if not controlled_node.floor_ray.is_colliding():
		controlled_node.direction *= -1
		return

	if controlled_node.player_ray.is_colliding():
		var collider = controlled_node.player_ray.get_collider()

		if collider is Player:
			state_machine.change_to("Chase(exploSqueleton)")
