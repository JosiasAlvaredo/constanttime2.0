extends State_base


func on_physics_process(delta):

	# Movimiento horizontal mientras cae
	controlled_node.velocity.x = controlled_node.direction * controlled_node.speed

	# Gravedad
	controlled_node.velocity.y += controlled_node.gravity * delta

	# Movimiento
	controlled_node.move_and_slide()

	# Cuando toca el suelo
	if controlled_node.is_on_floor():
		state_machine.change_to("Idle(slime)")
