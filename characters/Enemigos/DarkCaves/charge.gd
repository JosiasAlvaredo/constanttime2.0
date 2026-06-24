extends State_base

func start():
	var direction=controlled_node.direction
	
	

	controlled_node.velocity.x=direction*controlled_node.speed
	var origin_knockback=controlled_node.knockback
	controlled_node.knockback=Vector2(-100,-100)
	await get_tree().create_timer(0.5).timeout
	controlled_node.velocity.x=-direction*10
	controlled_node.Knockback_resistence=0
	controlled_node.knockback=Vector2(-600,-100)

	await get_tree().create_timer(0.125).timeout
	controlled_node.velocity.x=direction*800
	controlled_node.knockback=origin_knockback
	controlled_node.Knockback_resistence=1
	
	await get_tree().create_timer(1).timeout
	state_machine.change_to("Idle")
