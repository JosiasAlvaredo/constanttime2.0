
extends State_base


func start() -> void:
	pass


func on_process(delta: float) -> void:
	if controlled_node.playerUbi != null:
		state_machine.change_to("Attack(totem)")
