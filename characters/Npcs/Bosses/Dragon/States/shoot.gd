extends State_base

var dragon: Dragon

@export var projectile_scene: PackedScene
@export var amount := 5
@export var time_between_shots := 0.15
@export var dispersion := 15.0

var shooting := false


func start() -> void:
	dragon = controlled_node
	shooting = true
	shoot()


func shoot() -> void:
	if projectile_scene == null:
		push_error("No se asignó el proyectil en Shoot")
		state_machine.change_to("Idle")
		return

	if dragon.playerUbi == null:
		state_machine.change_to("Idle")
		return

	var shoot_point: Marker2D = dragon.get_node("ShootPoint")

	for i in range(amount):
		if not shooting:
			return

		var projectile = projectile_scene.instantiate()
		get_tree().current_scene.add_child(projectile)

		projectile.global_position = shoot_point.global_position

		var direction: Vector2 = (
			dragon.playerUbi.global_position -
			shoot_point.global_position
		).normalized()

		var random_angle := randf_range(-dispersion, dispersion)
		direction = direction.rotated(deg_to_rad(random_angle))

		projectile.directionP = direction

		await get_tree().create_timer(time_between_shots).timeout

	shooting = false
	state_machine.change_to("Idle")


func end() -> void:
	shooting = false
