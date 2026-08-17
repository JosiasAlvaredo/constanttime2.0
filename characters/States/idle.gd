extends State_base
func on_physics_process(delta: float) -> void:
	controlled_node.velocity.x=0
	
func on_input(event: InputEvent) -> void:
	if (Input.is_action_pressed("Left") or Input.is_action_pressed("Right")) and  not Input.is_action_pressed("Crouch"):
		state_machine.change_to("Move")
	
	if Input.is_action_pressed("Jump"):
		state_machine.change_to("Jump")
		
	if Input.is_action_just_pressed("Left_hand"):
		state_machine.change_to("Idle_action_Left_Hand")
	elif Input.is_action_just_pressed("Right_hand"):
		state_machine.change_to("Idle_action_Right_Hand")
	
	if controlled_node.current_torso!=null:
		if controlled_node.current_torso.has_method("conect_Idle"):
			controlled_node.current_torso.conect_Idle(controlled_node,state_machine)
