extends State_base


func start() -> void:

	var enemy = controlled_node

	enemy.velocity = Vector2.ZERO


func end() -> void:
	pass


func on_physics_process(delta: float) -> void:

	var enemy = controlled_node


	# ==============================
	# DETECTAR AL JUGADOR
	# ==============================

	if enemy.can_see_player():

		enemy.playerUbi = enemy.player.global_position

		state_machine.change_to("Shoot")

		return


	# ==============================
	# PATRULLAR
	# ==============================

	enemy.velocity.x = enemy.direction * enemy.speed


	# ==============================
	# PARED
	# ==============================

	if enemy.wall_ray.is_colliding():

		enemy.direction *= -1

		enemy.wall_ray.target_position.x *= -1


	# ==============================
	# FIN DEL TECHO
	# ==============================

	if not enemy.ceiling_ray.is_colliding():

		enemy.direction *= -1

		enemy.wall_ray.target_position.x *= -1


	# ==============================
	# MOVER
	# ==============================

	enemy.move_and_slide()
