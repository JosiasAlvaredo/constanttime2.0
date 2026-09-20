extends State_base

var arañalobo

@export var projectile_scene: PackedScene


func start() -> void:
	arañalobo = controlled_node

	if arañalobo == null:
		push_error("Shoot: arañalobo es null")
		return

	shoot_projectile()


func shoot_projectile() -> void:
	if projectile_scene == null:
		push_error("Shoot: no se asignó projectile_scene")
		state_machine.change_to("Idle")
		return

	if arañalobo.playerUbi == null:
		state_machine.change_to("Idle")
		return

	var shoot_point: Marker2D = arañalobo.get_node("ShootPoint")

	var projectile = projectile_scene.instantiate()

	get_tree().current_scene.add_child(projectile)

	projectile.global_position = shoot_point.global_position

	var direction: Vector2 = (
		arañalobo.playerUbi.global_position
		- shoot_point.global_position
	).normalized()

	projectile.direcionP = direction

	state_machine.change_to("Idle")


func end() -> void:
	pass
