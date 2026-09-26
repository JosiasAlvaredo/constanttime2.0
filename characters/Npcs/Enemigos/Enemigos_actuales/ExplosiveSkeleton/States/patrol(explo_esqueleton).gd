extends State_base

func start() -> void:
	controlled_node.direction=controlled_node.sprite.scale.x

func on_physics_process(delta: float) -> void:
	if controlled_node.player == null:
		controlled_node.player = get_tree().get_first_node_in_group("player")

	controlled_node.velocity.x = controlled_node.direction * controlled_node.speed

	if controlled_node.wall_ray.is_colliding():
		controlled_node.direction *= 1
		return

	if not controlled_node.floor_ray.is_colliding():
		controlled_node.direction *= -1
		return
