extends State_base

var timer := 0.0


func start():
	timer = 0.0
	controlled_node.velocity.x = 0


func on_physics_process(delta):
	var enemy = controlled_node

	enemy.velocity.x = 0

	if enemy.player == null:
		state_machine.change_to("Patrol(MS)")
		return

	if not enemy.can_see_player():
		state_machine.change_to("Patrol(MS)")
		return

	timer -= delta

	if timer <= 0:
		enemy.shoot()
		timer = enemy.shoot_cooldown
