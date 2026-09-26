extends State_base

func start():
	controlled_node.core_back.play("damage")
	controlled_node.core_front.play("damage")
	for wall in controlled_node.walls:
		wall.play("wall_damage")
	controlled_node.rain.drop()
	controlled_node.rain.drop()
	controlled_node.rain.drop()
	await get_tree().create_timer(4.0/5.0).timeout
	state_machine.change_to("Idle")
	
