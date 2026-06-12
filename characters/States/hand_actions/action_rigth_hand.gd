extends State_base

func action_start(State,controlled_node,state_machine):
	controlled_node.hand_using="Right"
	
	if GlobalValues.Right_hand:
		if GlobalValues.Right_hand.kind=="Bullet":
			GlobalValues.Right_hand=GlobalValues.Right_hand.use(controlled_node)
			var target=controlled_node.bullet_ray.get_collider()
			
			if target:
				if target.has_method("damage"):
					target.damage()
			state_machine.change_to(State)
			
		if GlobalValues.Right_hand:			
			if GlobalValues.Left_hand.kind=="Mele":
				
				if Input.is_action_pressed("Up"):
					controlled_node.mele_up_collition.disabled=false
				elif Input.is_action_pressed("Crouch") and not controlled_node.is_on_floor():
					controlled_node.mele_down_collition.disabled=false
				else:
					controlled_node.mele_front_collition.disabled=false
					
				await get_tree().create_timer(0.2).timeout
				
				controlled_node.mele_front_collition.disabled=true
				controlled_node.mele_down_collition.disabled=true
				controlled_node.mele_up_collition.disabled=true
				state_machine.change_to(State)
				
		controlled_node.hand_using=""
		
	else:
		controlled_node.hand_using="Right"
		controlled_node.Interactive_Box_collition.disabled=false
		await get_tree().create_timer(0.2).timeout
		controlled_node.hand_using=""
		controlled_node.Interactive_Box_collition.disabled=true
		state_machine.change_to(State)
