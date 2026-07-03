extends State_base
var direction

func on_physics_process(delta: float) -> void:
	
	direction=controlled_node.direction
	
	if direction!=0: 
		controlled_node.FLIP()
	
	controlled_node.animated_sprite_2d.play(controlled_node.animations["move"])
	
	controlled_node.velocity.x=direction*controlled_node.run_speed
	controlled_node.knockback=controlled_node.run_knockback
	
	if controlled_node.front_ray.is_colliding() or (not controlled_node.floor_detection.is_colliding() and controlled_node.is_on_floor()):
		controlled_node.velocity.y=controlled_node.Jump_stength
