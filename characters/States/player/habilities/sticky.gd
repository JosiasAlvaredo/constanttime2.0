extends State_base
var init_direction_x
var can_roll=true

var corner_up=false
var corner_down=false
func start():
	init_direction_x=-sign(controlled_node.body.scale.x)
	corner_up=false
	corner_down=false
	

func on_physics_process(delta: float) -> void:

	if controlled_node.velocity==Vector2(0,0):
		if controlled_node.is_on_floor():
			state_machine.change_to("Idle")
	
	if controlled_node.body_up.is_colliding() and not controlled_node.body_down.is_colliding():
		corner_down=true
		
	if controlled_node.body_up.is_colliding() and controlled_node.body_down.is_colliding():
		corner_down=false
		
	if corner_down and not controlled_node.body_up.is_colliding() and not controlled_node.body_down.is_colliding():
		if controlled_node.is_on_floor():
			state_machine.change_to("Idle")
		else:
			state_machine.change_to("Fall")
	else:
		controlled_node.velocity.y=sign(controlled_node.velocity.y)
		
func on_input(event: InputEvent) -> void:
	
	var direction_x=Input.get_axis("Right","Left")
	
	if Input.is_action_pressed("Jump"):
		controlled_node.velocity.y=controlled_node.Jump_stength
		controlled_node.velocity.x=-300*sign(controlled_node.body.scale.x)
		state_machine.change_to("Jump")
	
	if direction_x!=init_direction_x and direction_x!=0:
		controlled_node.velocity.y=controlled_node.Jump_stength
		state_machine.change_to("Fall")

	if Input.is_action_pressed("Up") or Input.is_action_pressed("Crouch"):
		state_machine.change_to("Climb")
		
# funciones unicas de habilidades, para conectar con los estados a las habilidades
func on_create():
	pass
	
	
func conect_jump (controlled_node,state_machine):
	if controlled_node.body_up.is_colliding():
		
		state_machine.change_to("Sticky")
	
func conect_fall (controlled_node,state_machine):
	if controlled_node.body_up.is_colliding():
			state_machine.change_to("Sticky")

		
