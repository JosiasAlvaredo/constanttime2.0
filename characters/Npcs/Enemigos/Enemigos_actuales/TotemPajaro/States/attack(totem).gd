
extends State_base


func start() -> void:
	controlled_node.shoot()
	state_machine.change_to("Cooldown(totem)")
