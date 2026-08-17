extends State_base
var direction

func on_physics_process(delta: float) -> void:
	
	direction=controlled_node.direction
	if direction!=0: 
		controlled_node.FLIP()
	
	

	controlled_node.velocity.x=direction*controlled_node.speed

	if controlled_node.velocity==Vector2(0,0):
		
		state_machine.change_to("Idle")
			
	if controlled_node.velocity.y>0:
		
		state_machine.change_to("Fall")
	
func on_input(event: InputEvent) -> void:
	
	if Input.is_action_pressed("Jump"):
		state_machine.change_to("Jump")
			
	if Input.is_action_just_pressed("Left_hand"):
		state_machine.change_to("Move_action_Left_Hand")
	elif Input.is_action_just_pressed("Right_hand"):
		state_machine.change_to("Move_action_Right_Hand")
		
	if controlled_node.current_torso!=null:
		if controlled_node.current_torso.has_method("conect_move"):
			controlled_node.current_torso.conect_move(controlled_node,state_machine)
	
