extends State_base
var direction

func start():
	controlled_node.can_jump=false

	if controlled_node.velocity.y==0:
		controlled_node.velocity.y=controlled_node.Jump_stength

func on_physics_process(delta: float) -> void:
	direction=controlled_node.direction
	if direction!=0: 
		controlled_node.FLIP()
	
	controlled_node.velocity.x=move_toward(controlled_node.velocity.x,direction*controlled_node.speed,controlled_node.aceleration)
	
	
	if controlled_node.velocity.y>=0:
		state_machine.change_to("Fall")
		


func on_input(event: InputEvent) -> void:
	
	if Input.is_action_just_released("Jump"):
		controlled_node.velocity.y=-100
		
	if controlled_node.current_torso!=null:
		if controlled_node.current_torso.has_method("conect_jump"):
			controlled_node.current_torso.conect_jump(controlled_node,state_machine)
		
	if Input.is_action_just_pressed("Left_hand"):
		state_machine.change_to("Jump_action_Right_Hand")
	elif Input.is_action_just_pressed("Right_hand"):
		state_machine.change_to("Jump_action_Left_Hand")
