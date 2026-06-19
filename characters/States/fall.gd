extends State_base
var direction

	
func on_physics_process(delta: float) -> void:
	direction=controlled_node.direction
	if direction!=0: 
		controlled_node.FLIP()
	
	controlled_node.animated_sprite_2d.play(controlled_node.animations["fall"])
	
	controlled_node.velocity.x=move_toward(controlled_node.velocity.x,direction*controlled_node.speed,controlled_node.aceleration)
	
	if controlled_node.velocity.y==0 and controlled_node.velocity.x==0:
		state_machine.change_to("Idle")
		controlled_node.can_jump=true
	elif controlled_node.velocity.y==0:
		controlled_node.can_jump=true
		state_machine.change_to("Move")
		
	if (controlled_node.can_jump or controlled_node.velocity.y==0) and Input.is_action_pressed("Jump"):
		state_machine.change_to("Jump")
		
	if controlled_node.can_jump:
		coyote_time()
	
func on_input(event: InputEvent) -> void:

	if controlled_node.body_up.is_colliding() and (Input.is_action_pressed("Up") or Input.is_action_pressed("Crouch")):
		state_machine.change_to("Climb")
		
	if Input.is_action_just_pressed("Left_hand"):
		state_machine.change_to("Fall_action_Left_Hand")
	elif Input.is_action_just_pressed("Right_hand"):
		state_machine.change_to("Fall_action_Right_Hand")
			
func coyote_time():
	await get_tree().create_timer(0.07).timeout
	controlled_node.can_jump=false
	
