extends State_base


func start():
	pass


func on_process(delta):
	if controlled_node.playerUbi != null:
		state_machine.change_to("Attack(totem)")
