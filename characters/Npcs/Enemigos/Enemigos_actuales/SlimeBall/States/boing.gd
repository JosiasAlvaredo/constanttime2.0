extends State_base
	
func on_physics_process(delta: float) -> void:
	controlled_node.velocity=controlled_node.speed*controlled_node.vectorDirection
