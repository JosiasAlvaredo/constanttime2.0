extends State_base


func start():
	controlled_node.direction=controlled_node.sprite_2d.scale.x

	var enemy = controlled_node

	enemy.velocity = Vector2.ZERO

	enemy.update_rays_direction()
	enemy.update_sprite_direction()


func end() -> void:
	pass


func on_physics_process(delta: float) -> void:

	var enemy = controlled_node


	# ==========================================
	# TODAVÍA ESTÁ SUBIENDO AL TECHO
	# ==========================================

	# Spider.gd se ocupa de esto.
	if enemy.llegando_al_techo:
		return


	# ==========================================
	# DETECTAR AL JUGADOR
	# ==========================================

	if enemy.can_see_player():

		enemy.playerUbi = enemy.player.global_position

		state_machine.change_to("Shoot")

		return


	# ==========================================
	# CAMINAR POR EL TECHO
	# ==========================================

	enemy.velocity.y = 0
	enemy.velocity.x = enemy.direction * enemy.speed


	# ==========================================
	# PARED
	# ==========================================

	if enemy.wall_ray.is_colliding():

		enemy.direction *= -1

		enemy.update_rays_direction()
		enemy.update_sprite_direction()


	# ==========================================
	# FIN DEL TECHO
	# ==========================================

	elif not enemy.ceiling_ray.is_colliding():

		enemy.direction *= -1

		enemy.update_rays_direction()
		enemy.update_sprite_direction()


	# ==========================================
	# MOVER
	# ==========================================

	enemy.move_and_slide()
