extends State_base

var direction
var used=false
func start():
	used=true
	controlled_node.velocity.y=0
	state_machine.change_to("Jump")
# funciones unicas de habilidades, para onectar con los estados a las habilidades
	
func conect_jump (controlled_node,state_machine):
	
		
	if Input.is_action_just_pressed("Jump") and not used:
		state_machine.change_to("Doble_jump")
	
func conect_fall (controlled_node,state_machine):
	if Input.is_action_just_pressed("Jump") and not used:
		state_machine.change_to("Doble_jump")


func _physics_process(delta: float) -> void:
	if state_machine!=null:
		if state_machine.current_state!=$"../../default_states/Jump" and state_machine.current_state!=$"../../default_states/Fall" and state_machine.current_state!=self and used:
				used=false
				return
