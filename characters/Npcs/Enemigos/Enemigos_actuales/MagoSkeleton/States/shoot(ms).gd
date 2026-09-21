
extends State_base

var timer := 0.0


func start() -> void:
	var enemy = controlled_node

	enemy.velocity.x = 0
	timer = 0.0


func on_physics_process(delta: float) -> void:
	var enemy = controlled_node

	enemy.velocity.x = 0

	if enemy.player_objetivo == null:
		state_machine.change_to("Patrol(MS)")
		return

	if not enemy.can_see_player():
		state_machine.change_to("Patrol(MS)")
		return

	if enemy.player_objetivo.global_position.x > enemy.global_position.x:
		if enemy.direction != 1:
			enemy.direction = 1
			enemy.update_direction()
	else:
		if enemy.direction != -1:
			enemy.direction = -1
			enemy.update_direction()

	timer -= delta

	if timer > 0:
		return

	if enemy.projectile_scene == null:
		return

	var projectile = enemy.projectile_scene.instantiate()

	get_tree().current_scene.add_child(projectile)

	projectile.global_position = enemy.shoot_point.global_position

	var player_position = enemy.player_objetivo.global_position

	projectile.directionPlayer = (
		player_position - projectile.global_position
	).normalized()

	timer = enemy.shoot_cooldown
