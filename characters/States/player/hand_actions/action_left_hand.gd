extends State_base

func action_start(State,controlled_node,state_machine):
	var left_hand_action=controlled_node.left_hand_action
	
	if left_hand_action!=null and not controlled_node.mouse_on_menu:
		left_hand_action.call(State)
	else:
		state_machine.change_to(State)
		
