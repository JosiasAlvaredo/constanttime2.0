extends State_base

func on_physics_process(delta: float) -> void:
	controlled_node.velocity.x=0
	controlled_node.animated_sprite_2d.play("Crouched")
	controlled_node.stand_up_collition.disabled=true
	
func on_input(event: InputEvent) -> void:

	if Input.is_action_just_pressed("Left") or Input.is_action_pressed("Right"):
		if controlled_node.can_roll:
			controlled_node.delay_roll()
			await get_tree().create_timer(0.025).timeout
			state_machine.change_to("Roll")
			
			print(controlled_node.direction)
			
	if not controlled_node.crouch_ray.is_colliding():
		
		if not Input.is_action_pressed("Crouch"):
			controlled_node.stand_up_collition.disabled=false
			state_machine.change_to("Idle")
		
		if Input.is_action_pressed("Jump"):
			controlled_node.stand_up_collition.disabled=false
			state_machine.change_to("Jump")
