extends State_base
func on_physics_process(delta: float) -> void:
	controlled_node.velocity.x=0
	controlled_node.animated_sprite_2d.play("Idle")

func on_input(event: InputEvent) -> void:
	if (Input.is_action_pressed("Left") or Input.is_action_pressed("Right")) and  not Input.is_action_pressed("Crouch"):
		state_machine.change_to("Move")
	elif not (Input.is_action_pressed("Left") or Input.is_action_pressed("Right")) and Input.is_action_pressed("Crouch"):
		state_machine.change_to("Crouched")
	elif (Input.is_action_pressed("Left") or Input.is_action_pressed("Right")) and Input.is_action_pressed("Run") and Input.is_action_pressed("Crouch"):
		state_machine.change_to("Roll")
	
	if Input.is_action_pressed("Jump"):
		state_machine.change_to("Jump")
		
	if Input.is_action_pressed("Left_hand"):
		state_machine.change_to("Action_Left_Hand")
	elif Input.is_action_pressed("Right_hand"):
		state_machine.change_to("Action_Rigth_Hand")
	
	if controlled_node.body_up.is_colliding() and Input.is_action_pressed("Up"):
		state_machine.change_to("Climb")
