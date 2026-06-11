extends State_base
var direction

func start():
	controlled_node.can_jump=false
	controlled_node.animated_sprite_2d.play(controlled_node.animations["jump"])
	controlled_node.velocity.y=controlled_node.Jump_stength

func on_physics_process(delta: float) -> void:
	direction=controlled_node.direction
	if direction!=0: 
		controlled_node.FLIP()
	
	controlled_node.velocity.x=direction*controlled_node.speed

	
	if controlled_node.velocity.y>=0:
		state_machine.change_to("Fall")
		


func on_input(event: InputEvent) -> void:
	
	if Input.is_action_just_released("Jump"):
		controlled_node.velocity.y=-100
		
	if controlled_node.body_up.is_colliding() and (Input.is_action_pressed("Up") or Input.is_action_pressed("Crouch")):
		state_machine.change_to("Climb")
		
	if Input.is_action_just_pressed("Left_hand"):
		state_machine.change_to("Jump_action_Left_Hand")
	elif Input.is_action_just_pressed("Right_hand"):
		state_machine.change_to("Jump_action_Right_Hand")
