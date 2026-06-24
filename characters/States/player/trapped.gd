extends State_base
func start():
	controlled_node.velocity=Vector2.ZERO
	
func on_input(event: InputEvent) -> void:
		
	if Input.is_action_just_pressed("Left_hand"):
		state_machine.change_to("Trapped_action_Left_Hand")
	elif Input.is_action_just_pressed("Right_hand"):
		state_machine.change_to("Trapped_action_Right_Hand")
