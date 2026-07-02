extends State_base

func start():
	print("ENTRÉ A WALK")

func on_physics_process(_delta):
	if controlled_node.player == null:
		return
	controlled_node.distance = controlled_node.player.global_position - controlled_node.global_position
	
	if controlled_node.can_attack:
		if controlled_node.player_is_right() \
		and controlled_node.player_distance() <= controlled_node.melee_distance \
		and controlled_node.can_attack:
			state_machine.change_to("AttackR")
			return
	
		if controlled_node.player_is_left() \
		and controlled_node.player_distance() >= controlled_node.summon_distance \
		and controlled_node.can_summon:
			state_machine.change_to("AttackL")
			return
	
	if controlled_node.distance.x > 0:
		controlled_node.velocity.x = controlled_node.SPEED
		controlled_node.animated_sprite_2d.play(controlled_node.animations["WalkR"])
	else:
		controlled_node.velocity.x = -controlled_node.SPEED
		controlled_node.animated_sprite_2d.play(controlled_node.animations["WalkL"])
