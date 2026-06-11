extends State_base
var direction

func on_physics_process(delta: float) -> void:
	
	direction=controlled_node.direction
	if direction!=0: 
		controlled_node.FLIP()
	
	controlled_node.animated_sprite_2d.play(controlled_node.animations["move"])

	controlled_node.velocity.x=direction*controlled_node.speed

	if controlled_node.velocity==Vector2(0,0):
		
		state_machine.change_to("Idle")
			
	if controlled_node.velocity.y>0:
		
		state_machine.change_to("Fall")
	
func on_input(event: InputEvent) -> void:
	
	if Input.is_action_pressed("Jump"):
		state_machine.change_to("Jump")
		
	if Input.is_action_pressed("Crouch"):
		if controlled_node.can_roll:
			state_machine.change_to("Roll")
			controlled_node.delay_roll()
			

	if controlled_node.body_up.is_colliding() and (Input.is_action_pressed("Up") or Input.is_action_pressed("Crouch")):
		state_machine.change_to("Climb")

		

		
