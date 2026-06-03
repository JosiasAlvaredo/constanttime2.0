extends State_base

func start():
	if controlled_node.Left_hand:
		if controlled_node.Left_hand.kind=="Bullet":
			controlled_node.Left_hand=controlled_node.Left_hand.use()
			var target=controlled_node.bullet.get_collider()
			if target:
				if target.has_method("dead"):
					target.dead()
			state_machine.change_to("Idle")
		if controlled_node.Left_hand:			
			if controlled_node.Left_hand.kind=="Mele":
				controlled_node.Left_hand=controlled_node.Left_hand.use()
				
				controlled_node.mele_collision.disabled=false
				await get_tree().create_timer(0.2).timeout
				controlled_node.mele_collision.disabled=true
				state_machine.change_to("Idle")
		
	else:
		controlled_node.hand_using="Left"
		controlled_node.Interactive_Box_collition.disabled=false
		await get_tree().create_timer(0.2).timeout
		controlled_node.hand_using=""
		controlled_node.Interactive_Box_collition.disabled=true
		state_machine.change_to("Idle")
