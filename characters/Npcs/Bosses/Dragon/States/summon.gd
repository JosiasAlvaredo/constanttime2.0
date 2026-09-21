extends State_base

var dragon: Dragon

@export var enemy_scene: PackedScene


func start() -> void:
	dragon = controlled_node

	if enemy_scene == null:
		push_error("❌ No se asignó el enemigo en Summon")
		state_machine.change_to("Idle")
		return

	if dragon.playerUbi == null:
		push_error("❌ Dragon no tiene playerUbi")
		state_machine.change_to("Idle")
		return

	var marker1 = dragon.get_node_or_null("SummonPoint1")
	var marker2 = dragon.get_node_or_null("SummonPoint2")

	if marker1 == null:
		push_error("❌ No se encontró SummonPoint1")

	if marker2 == null:
		push_error("❌ No se encontró SummonPoint2")

	if marker1 == null or marker2 == null:
		state_machine.change_to("Idle")
		return

	invocar_enemigo(marker1)
	invocar_enemigo(marker2)

	state_machine.change_to("Idle")


func invocar_enemigo(marker: Marker2D) -> void:
	var enemigo = enemy_scene.instantiate()

	get_tree().current_scene.add_child(enemigo)

	enemigo.global_position = marker.global_position

	if "playerUbi" in enemigo:
		enemigo.playerUbi = dragon.playerUbi


func end() -> void:
	pass
