extends State_base


func start() -> void:
	print("ENTRO A PATROL")


func on_physics_process(delta: float) -> void:
	var enemy = controlled_node

	# Movimiento
	enemy.velocity.x = enemy.direction * enemy.speed

	# Detectar pared
	if enemy.wall_ray.is_colliding():
		enemy.change_direction()
		return

	# Detectar precipicio
	if not enemy.floor_ray.is_colliding():
		enemy.change_direction()
		return

	# Detectar jugador
	if enemy.player_ray.is_colliding():
		var collider = enemy.player_ray.get_collider()

		if collider.is_in_group("player"):
			state_machine.change_to("Attack(Sr)")
			return

	enemy.move_and_slide()
