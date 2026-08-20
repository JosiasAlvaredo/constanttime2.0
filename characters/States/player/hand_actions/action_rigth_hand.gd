extends State_base

func action_start(State,controlled_node,state_machine):
	var right_hand_action=controlled_node.right_hand_action
	
	if right_hand_action!=null:
		right_hand_action.call(State)
		
