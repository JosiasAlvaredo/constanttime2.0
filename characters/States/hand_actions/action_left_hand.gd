extends State_base

func action_start(State,controlled_node,state_machine):
	controlled_node.hand_using="Left"
	if GlobalValues.Left_hand:
		
		if GlobalValues.Left_hand.kind=="Bullet":
			var target=controlled_node.bullet.get_collider()
			GlobalValues.Left_hand=GlobalValues.Left_hand.use(controlled_node)

			if target:
				if target.has_method("damage"):
					target.damage(controlled_node)
			state_machine.change_to(State)
			
		if GlobalValues.Left_hand:
			
			if GlobalValues.Left_hand.kind=="Mele":
				GlobalValues.Left_hand=GlobalValues.Left_hand.use(controlled_node)
				controlled_node.mele_collision.disabled=false
				await get_tree().create_timer(0.2).timeout
				controlled_node.mele_collision.disabled=true
				state_machine.change_to(State)
		controlled_node.hand_using=""
	else:
		controlled_node.hand_using="Left"
		controlled_node.Interactive_Box_collition.disabled=false
		await get_tree().create_timer(0.2).timeout
		controlled_node.hand_using=""
		controlled_node.Interactive_Box_collition.disabled=true
		state_machine.change_to(State)
