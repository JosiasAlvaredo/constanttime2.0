extends State_base

@export var idle_time: float = 0.5

var timer := 0.0


func start():

	timer = idle_time
	controlled_node.velocity.x = 0


func on_physics_process(delta):

	timer -= delta

	# Gravedad
	controlled_node.velocity.y += controlled_node.gravity * delta

	controlled_node.move_and_slide()

	if timer <= 0:
		state_machine.change_to("Slide(BSlime)")
