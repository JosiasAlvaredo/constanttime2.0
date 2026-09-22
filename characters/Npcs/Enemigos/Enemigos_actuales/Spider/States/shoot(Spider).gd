extends State_base


@export var spread_angle := 15.0
@export var shoot_cooldown := 1.0

var timer := 0.0


func start() -> void:

	var enemy = controlled_node

	enemy.velocity = Vector2.ZERO

	timer = shoot_cooldown


func end() -> void:
	pass


func on_physics_process(delta: float) -> void:

	var enemy = controlled_node

	enemy.velocity = Vector2.ZERO

	timer -= delta

	if timer > 0:
		return


	# ==========================================
	# COMPROBAR JUGADOR
	# ==========================================

	if enemy.player == null:

		state_machine.change_to("Patrol")

		return


	# ==========================================
	# COMPROBAR SI TODAVÍA LO VE
	# ==========================================

	if not enemy.can_see_player():

		state_machine.change_to("Patrol")

		return


	# ==========================================
	# GUARDAR POSICIÓN DEL JUGADOR
	# ==========================================

	enemy.playerUbi = enemy.player.global_position


	# ==========================================
	# GIRAR HACIA EL JUGADOR
	# ==========================================

	if enemy.player.global_position.x > enemy.global_position.x:

		enemy.direction = 1

	elif enemy.player.global_position.x < enemy.global_position.x:

		enemy.direction = -1


	enemy.update_rays_direction()
	enemy.update_sprite_direction()


	# ==========================================
	# DIRECCIÓN HACIA EL JUGADOR
	# ==========================================

	var directionP: Vector2 = (
		enemy.shoot_point.global_position
		.direction_to(enemy.playerUbi)
	)


	# ==========================================
	# PROYECTIL CENTRAL
	# ==========================================

	disparar_proyectil(
		enemy,
		directionP
	)


	# ==========================================
	# PROYECTIL +15°
	# ==========================================

	disparar_proyectil(
		enemy,
		directionP.rotated(
			deg_to_rad(spread_angle)
		)
	)


	# ==========================================
	# PROYECTIL -15°
	# ==========================================

	disparar_proyectil(
		enemy,
		directionP.rotated(
			deg_to_rad(-spread_angle)
		)
	)


	# ==========================================
	# VOLVER A PATRULLAR
	# ==========================================

	state_machine.change_to("Patrol")


func disparar_proyectil(
	enemy,
	directionP: Vector2
) -> void:

	if enemy.projectile_scene == null:

		push_error("No se asignó projectile_scene")

		return


	var projectile = enemy.projectile_scene.instantiate()

	projectile.global_position = enemy.shoot_point.global_position

	projectile.direcionP = directionP

	get_tree().current_scene.add_child(projectile)
