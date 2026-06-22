extends State_base
var directions

func on_physics_process(delta: float) -> void:
	
	directions=controlled_node.directions
	
	controlled_node.animated_sprite_2d.play(controlled_node.animations["move"])

	controlled_node.velocity=directions*controlled_node.speed

	if controlled_node.velocity==Vector2(0,0):
		state_machine.change_to("Idle")
			
