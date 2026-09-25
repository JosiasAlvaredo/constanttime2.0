extends State_base

func start():
	controlled_node.core_back.play("core")
	controlled_node.core_front.play("core")
	for wall in controlled_node.walls:
		wall.play("default")
