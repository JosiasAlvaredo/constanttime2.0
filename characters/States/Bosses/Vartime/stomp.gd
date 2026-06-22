extends State_base
func start():
	await get_tree().create_timer(0.15).timeout
	controlled_node.velocity.y=controlled_node.stomp_velocity

func on_physics_process(delta: float) -> void:
	if controlled_node.is_on_floor():
		state_machine.change_to("Idle_vartime")
