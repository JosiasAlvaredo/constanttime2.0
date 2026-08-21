extends State_base

var timer := 0.0


func start():
	timer = controlled_node.idle_time


func on_physics_process(delta):
	timer -= delta

	if timer <= 0:
		state_machine.change_to("Dash(ExploSkeleton)")
