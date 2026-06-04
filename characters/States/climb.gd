extends State_base
var direction_y
var init_direction_x
var can_roll=true

var corner_up=false
var corner_down=false
func start():
	init_direction_x=-sign(controlled_node.animated_sprite_2d.scale.x)
	corner_up=false
	corner_down=false

func on_physics_process(delta: float) -> void:
	direction_y=controlled_node.direction_y
	controlled_node.animated_sprite_2d.play("Climb")

	if controlled_node.velocity==Vector2(0,0):
		controlled_node.animated_sprite_2d.pause()
		
		if controlled_node.is_on_floor():
			state_machine.change_to("Idle")
	
	if not controlled_node.body_up.is_colliding() and controlled_node.body_down.is_colliding():
		corner_up=true
	if controlled_node.body_up.is_colliding() and controlled_node.body_down.is_colliding():
		corner_up=false
		
	if controlled_node.body_up.is_colliding() and not controlled_node.body_down.is_colliding():
		corner_down=true
		
	if controlled_node.body_up.is_colliding() and controlled_node.body_down.is_colliding():
		corner_up=false
		corner_down=false
		
	if corner_up and not controlled_node.body_up.is_colliding() and not controlled_node.body_down.is_colliding():
		controlled_node.velocity.x=direction_y*init_direction_x*controlled_node.Climb_velocity/5
		if controlled_node.is_on_floor():
			state_machine.change_to("Idle")
	elif  corner_down and not controlled_node.body_up.is_colliding() and not controlled_node.body_down.is_colliding():
		if controlled_node.is_on_floor():
			state_machine.change_to("Idle")
		else:
			state_machine.change_to("Fall")
	else:
		controlled_node.velocity.y=direction_y*controlled_node.Climb_velocity
		
func on_input(event: InputEvent) -> void:
	
	var direction_x=Input.get_axis("Right","Left")
	
	if Input.is_action_pressed("Jump"):
		state_machine.change_to("Jump")
	
	if direction_x!=init_direction_x and direction_x!=0:
		controlled_node.velocity.y=controlled_node.Jump_stength
		state_machine.change_to("Fall")

		

		
