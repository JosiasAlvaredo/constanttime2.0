extends State_base
var direction

func start():
	direction=controlled_node.direction
	controlled_node.velocity.x=direction*controlled_node.roll_velocity
	controlled_node.stand_up_collition.disabled=true
	if direction!=0:
		controlled_node.FLIP()
	await get_tree().create_timer(0.2).timeout
	controlled_node.velocity.x=0

func on_physics_process(delta: float) -> void:
	
	
	controlled_node.animated_sprite_2d.play("Crouched")
	
	
	if controlled_node.velocity.x==0:
		if direction==0:
			state_machine.change_to("Crouched")
		else:
			controlled_node.stand_up_collition.disabled=false
			if not controlled_node.crouch_ray.is_colliding():
				state_machine.change_to("Move")
			else:
				state_machine.change_to("Roll")


		
func on_input(event: InputEvent) -> void:
	if Input.is_action_pressed("Jump") and not controlled_node.crouch_ray.is_colliding():
		controlled_node.stand_up_collition.disabled=false
		state_machine.change_to("Jump")
