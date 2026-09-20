extends weapond_item_base_class

var current_state

func use(State):
	var fire_ball=load("res://objets/weapons_tools/bullets/fire_ball.tscn").instantiate()
	
	fire_ball.skills=skills
	fire_ball.global_position=global_position
	fire_ball.velocity = Vector2.RIGHT.rotated(global_position.angle_to_point(get_global_mouse_position())) * 200
		
	fire_ball.player=player
	player.get_parent().add_child(fire_ball)
	
	worn_out()
	
	current_state=State

		
	
	player.state_machine.change_to(State)
	player.hand_using=""

		
