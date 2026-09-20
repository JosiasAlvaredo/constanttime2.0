extends State_base

@export var spread_angle := 15.0
@export var shoot_cooldown := 1.0

var timer := 0.0


func start() -> void:
	var enemy = controlled_node

	enemy.velocity = Vector2.ZERO

	# No disparar inmediatamente al entrar
	timer = shoot_cooldown


func end() -> void:
	pass


func on_physics_process(delta: float) -> void:
	var enemy = controlled_node

	enemy.velocity = Vector2.ZERO

	# Esperar cooldown
	timer -= delta

	if timer > 0:
		return

	# Si no existe el jugador
	if enemy.player == null:
		state_machine.change_to("Patrol")
		return

	# Si ya no puede verlo
	if not enemy.can_see_player():
		state_machine.change_to("Patrol")
		return

	# Guardar posición del jugador
	enemy.playerUbi = enemy.player.global_position

	# Dirección hacia el jugador
	var directionP: Vector2 = (
		enemy.shoot_point.global_position
		.direction_to(enemy.playerUbi)
	)

	# Disparo central
	disparar_proyectil(
		enemy,
		directionP
	)

	# Disparo +15°
	disparar_proyectil(
		enemy,
		directionP.rotated(
			deg_to_rad(spread_angle)
		)
	)

	# Disparo -15°
	disparar_proyectil(
		enemy,
		directionP.rotated(
			deg_to_rad(-spread_angle)
		)
	)

	# Volver a patrulla
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
