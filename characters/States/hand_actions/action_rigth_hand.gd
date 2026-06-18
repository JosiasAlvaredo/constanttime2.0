extends State_base

func action_start(State,controlled_node,state_machine):
	var item=controlled_node.right_hand_item
	
	controlled_node.hand_using="Right"
	if item:
		item.use(State)
	else:
		controlled_node.Interactive_Box_collition.disabled=false
		await get_tree().create_timer(0.2).timeout
		controlled_node.hand_using=""
		controlled_node.Interactive_Box_collition.disabled=true
		state_machine.change_to(State)
