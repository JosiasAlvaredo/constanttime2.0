extends State_base

var dragon: Dragon

@export var enemy_scene: PackedScene


func start() -> void:
	dragon = controlled_node

	if enemy_scene == null:
		push_error("No se asignó el enemigo en Summon")
		state_machine.change_to("Idle")
		return

	if dragon.playerUbi == null:
		state_machine.change_to("Idle")
		return

	var marker1: Marker2D = dragon.get_node("SummonPoint1")
	var marker2: Marker2D = dragon.get_node("SummonPoint2")

	invocar_enemigo(marker1)
	invocar_enemigo(marker2)

	state_machine.change_to("Idle")


func invocar_enemigo(marker: Marker2D) -> void:

	var enemigo = enemy_scene.instantiate()

	get_tree().current_scene.add_child(enemigo)

	enemigo.global_position = marker.global_position

	# Pasamos el NODO del jugador, no su posición
	enemigo.playerUbi = dragon.playerUbi
