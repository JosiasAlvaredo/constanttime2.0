extends State_base

@export var impulse_speed: float = 180.0
@export var slide_time: float = 0.7

var timer := 0.0


func start():

	timer = slide_time

	# Impulso inicial
	controlled_node.velocity.x = (
		controlled_node.direction * impulse_speed
	)


func on_physics_process(delta):

	timer -= delta

	# Frenado progresivo
	controlled_node.velocity.x = move_toward(
		controlled_node.velocity.x,
		0,
		impulse_speed * 2.0 * delta
	)

	# Gravedad
	controlled_node.velocity.y += controlled_node.gravity * delta

	# Movimiento
	controlled_node.move_and_slide()


	# Si hay una pared
	if controlled_node.front_ray.is_colliding():

		controlled_node.change_direction()
		state_machine.change_to("Idle(BSlime)")
		return


	# Si no hay suelo adelante
	if not controlled_node.floor_ray.is_colliding():

		controlled_node.change_direction()
		state_machine.change_to("Idle(BSlime)")
		return


	# Terminó el impulso
	if timer <= 0:

		controlled_node.velocity.x = 0
		state_machine.change_to("Idle(BSlime)")
