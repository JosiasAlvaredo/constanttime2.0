extends State_base


func start():
	controlled_node.shoot()
	state_machine.change_to("Cooldown(totem)")
