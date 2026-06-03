extends State_base
var direction

func on_physics_process(delta: float) -> void:
	direction=controlled_node.direction
	if direction!=0: 
		controlled_node.FLIP()
	
	controlled_node.animated_sprite_2d.play("Jump")
	
	controlled_node.velocity.x=direction*controlled_node.speed
	
	if controlled_node.velocity.y==0 and controlled_node.velocity.x==0:
		state_machine.change_to("Idle")
	elif controlled_node.velocity.y==0:
		state_machine.change_to("Move")

func on_input(event: InputEvent) -> void:

	if controlled_node.body_up.is_colliding() and (Input.is_action_pressed("Up") or Input.is_action_pressed("Crouch")):
		state_machine.change_to("Climb")
