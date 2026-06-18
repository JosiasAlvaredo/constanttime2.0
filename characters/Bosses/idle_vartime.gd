extends State_base

func start() -> void:
	controlled_node.velocity.x=0
	controlled_node.animated_sprite_2d.play(controlled_node.animations["idle"])
	
	await get_tree().create_timer(1).timeout
	
	if abs(controlled_node.distance.x)<=50:
		state_machine.change_to("Short_sword")
		return
	else:
		state_machine.change_to("Teleport")
		
func on_physics_process(delta: float) -> void:
	controlled_node.FLIP()
