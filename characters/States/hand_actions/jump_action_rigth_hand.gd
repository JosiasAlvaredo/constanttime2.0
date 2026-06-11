extends State_base
@onready var acction=$"../Action_Right_Hand"
@onready var subState=$"../Jump"

var state="Jump"

func start():
	acction.action_start(state,controlled_node,state_machine)
	
func on_physics_process(delta: float) -> void:
	subState.on_physics_process(delta)
