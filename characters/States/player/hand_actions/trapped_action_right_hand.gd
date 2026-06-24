extends State_base
@onready var acction=$"../Action_Right_Hand"
@onready var subState=$"../Trapped"

var state="Trapped"

func start():
	acction.action_start(state,controlled_node,state_machine)
	
