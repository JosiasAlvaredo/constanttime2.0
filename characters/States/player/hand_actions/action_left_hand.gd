extends State_base

func action_start(State,controlled_node,state_machine):
	var left_hand_action=controlled_node.left_hand_action
	print(left_hand_action)
	
	if left_hand_action!=null:
		print(8)
		left_hand_action.call(State)
		
