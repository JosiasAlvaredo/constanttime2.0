extends State_base

var arañalobo

@export var enemy_scene: PackedScene
@export var summon_delay := 0.5


func start() -> void:
	arañalobo = controlled_node

	if arañalobo == null:
		push_error("Summon: arañalobo es null")
		return

	summon_enemies()


func summon_enemies() -> void:
	if enemy_scene == null:
		push_error("Summon: no se asignó enemy_scene")
		state_machine.change_to("Idle")
		return

	var summon_point_1: Marker2D = arañalobo.get_node("SummonPoint1")
	var summon_point_2: Marker2D = arañalobo.get_node("SummonPoint2")

	# Primer enemigo
	var enemy1 = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy1)
	enemy1.global_position = summon_point_1.global_position

	# Esperamos un poco antes del segundo
	await get_tree().create_timer(summon_delay).timeout

	if state_machine.current_state != self:
		return

	# Segundo enemigo
	var enemy2 = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy2)
	enemy2.global_position = summon_point_2.global_position

	state_machine.change_to("Idle")


func end() -> void:
	pass
