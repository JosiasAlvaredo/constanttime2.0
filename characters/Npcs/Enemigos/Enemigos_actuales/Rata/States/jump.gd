extends State_base


func start() -> void:
	var enemy = controlled_node
	controlled_node.sprite_2d.play("jump")
	enemy.velocity.y = enemy.Jump_stength


func on_physics_process(delta: float) -> void:
	var enemy = controlled_node
	
	enemy.velocity.y += enemy.gravity * delta
	
	if enemy.playerUbi != null:
		var difference = enemy.playerUbi.global_position.x - enemy.global_position.x
		
		if abs(difference) > 5:
			controlled_node.direction = sign(-difference)
			controlled_node.sprite_2d.scale.x=controlled_node.direction*abs(controlled_node.sprite_2d.scale.x)


		enemy.velocity.x = move_toward(
			enemy.velocity.x,
			enemy.direction * enemy.speed,
			enemy.aceleration * delta
		)
	
	enemy.move_and_slide()
	
	if enemy.velocity.y > 0:
		state_machine.change_to("Fall")
