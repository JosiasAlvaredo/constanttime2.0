extends State_base

@export var slide_time: float = 0.7

var timer := 0.0


func start():
	controlled_node.sprite.play("move")
	timer = slide_time
	if controlled_node.direction == 0:
		if controlled_node.sprite.flip_h and controlled_node.start_flip:
			controlled_node.direction=-1
		else:
			controlled_node.direction=1
		controlled_node.update_direction()
	# Impulso inicial
	controlled_node.velocity.x = (
		controlled_node.direction * controlled_node.speed
	)


func on_physics_process(delta):

	timer -= delta

	# Frenado progresivo
	controlled_node.velocity.x = move_toward(
		controlled_node.velocity.x,
		0,
		controlled_node.speed * 2.0 * delta
	)

	# Gravedad
	controlled_node.velocity.y += controlled_node.gravity * delta

	# Movimiento
	controlled_node.move_and_slide()


	# Si hay una pared
	if controlled_node.front_ray.is_colliding():

		controlled_node.change_direction()
		state_machine.change_to("Idle")
		return


	# Si no hay suelo adelante
	if not controlled_node.floor_ray.is_colliding():

		controlled_node.change_direction()
		state_machine.change_to("Idle")
		return


	# Terminó el impulso
	if timer <= 0:

		controlled_node.velocity.x = 0
		state_machine.change_to("Idle")
