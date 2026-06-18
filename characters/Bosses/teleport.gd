extends State_base
func start():
	controlled_node.animated_sprite_2d.play(controlled_node.animations["teleport"])

func on_physics_process(delta: float) -> void:
	if not controlled_node.animated_sprite_2d.is_playing():
		if int(controlled_node.distance.x) % 2==0:
			controlled_node.global_position.x=controlled_node.player.global_position.x
			controlled_node.global_position.y=-150
			state_machine.change_to("Stomp")
		else:
			controlled_node.global_position.x=controlled_node.player.global_position.x-70*controlled_node.direction
			controlled_node.FLIP()
			state_machine.change_to("Large_sword")
