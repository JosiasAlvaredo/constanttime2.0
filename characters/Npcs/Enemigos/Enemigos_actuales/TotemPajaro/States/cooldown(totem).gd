extends State_base

@export var cooldown_time := 1.5

var timer := 0.0


func start():
	timer = cooldown_time


func on_process(delta):
	timer -= delta

	if timer <= 0:
		if controlled_node.player != null:
			state_machine.change_to("Attack(totem)")
		else:
			state_machine.change_to("Idle(totem)")
