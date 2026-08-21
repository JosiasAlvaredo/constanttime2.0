extends State_base

var timer := 0.0


func start():
	timer = controlled_node.dash_time

	controlled_node.velocity.x = (
		controlled_node.direction *
		controlled_node.dash_speed
	)


func on_physics_process(delta):
	timer -= delta

	if controlled_node.front_ray.is_colliding():
		controlled_node.change_direction()
		state_machine.change_to("Idle(ExploSkeleton)")
		return

	if not controlled_node.floor_ray.is_colliding():
		controlled_node.change_direction()
		state_machine.change_to("Idle(ExploSkeleton)")
		return

	if timer <= 0:
		state_machine.change_to("Slide(ExploSkeleton)")
