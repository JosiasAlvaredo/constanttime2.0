extends State_base


func on_physics_process(delta):

	# Si hay una pared adelante
	if controlled_node.front_ray.is_colliding():
		controlled_node.change_direction()

	# Si no hay suelo adelante
	elif not controlled_node.floor_ray.is_colliding():
		controlled_node.change_direction()

	# Movimiento horizontal
	controlled_node.velocity.x = controlled_node.direction * controlled_node.speed

	# Gravedad
	controlled_node.velocity.y += controlled_node.gravity * delta

	# Movimiento
	controlled_node.move_and_slide()

	# Cuando empieza a caer
	if controlled_node.velocity.y > 0:
		state_machine.change_to("Fall(slime)")
