extends State_base

func action_start(State,controlled_node,state_machine):
	controlled_node.hand_using="Right"
	if GlobalValues.Right_hand:
		if GlobalValues.Right_hand.kind=="Bullet":
			GlobalValues.Right_hand=GlobalValues.Right_hand.use(controlled_node)
			var target=controlled_node.bullet.get_collider()
			if target:
				if target.has_method("damage"):
					target.damage()
			state_machine.change_to(State)
		if GlobalValues.Right_hand:			
			if GlobalValues.Right_hand.kind=="Mele":
				GlobalValues.Right_hand=GlobalValues.Right_hand.use(controlled_node)
				
				controlled_node.mele_collision.disabled=false
				await get_tree().create_timer(0.2).timeout
				controlled_node.mele_collision.disabled=true
				state_machine.change_to(State)
		controlled_node.hand_using=""
	else:
		controlled_node.hand_using="Right"
		controlled_node.Interactive_Box_collition.disabled=false
		await get_tree().create_timer(0.2).timeout
		controlled_node.hand_using=""
		controlled_node.Interactive_Box_collition.disabled=true
		state_machine.change_to(State)
