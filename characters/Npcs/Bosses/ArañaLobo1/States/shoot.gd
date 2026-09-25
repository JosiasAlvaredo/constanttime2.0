
extends State_base

var arañalobo

@export var projectile_scene: PackedScene


func start() -> void:
	arañalobo = controlled_node

	if arañalobo == null:
		push_error("Shoot: arañalobo es null")
		return

	shoot_projectiles()


func shoot_projectiles() -> void:
	if projectile_scene == null:
		push_error("Shoot: no se asignó projectile_scene")
		state_machine.change_to("Idle")
		return

	if arañalobo.playerUbi == null:
		state_machine.change_to("Idle")
		return

	var shoot_point: Marker2D = arañalobo.get_node("ShootPoint")

	var direction: Vector2 = (
		arañalobo.playerUbi.global_position
		- shoot_point.global_position
	).normalized()

	# Desviaciones de cada proyectil
	var angles := [
		-15.0,
		-5.0,
		5.0,
		15.0
	]

	for angle in angles:

		var projectile = projectile_scene.instantiate()

		get_tree().current_scene.add_child(projectile)

		projectile.global_position = shoot_point.global_position

		var projectile_direction := direction.rotated(
			deg_to_rad(angle)
		).normalized()

		projectile.direcionP = projectile_direction

	state_machine.change_to("Idle")


func end() -> void:
	pass
