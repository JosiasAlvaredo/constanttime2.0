extends State_base
var player_position:Vector2=Vector2.ZERO
func on_physics_process(delta: float) -> void:
	controlled_node.velocity.x=0
	var direction =player_position-controlled_node.globalposition
	

	
