extends State_base



func start():
	controlled_node.sprite.play("charge")

	await get_tree().create_timer(1).timeout
	state_machine.change_to("Jump(slime)")
