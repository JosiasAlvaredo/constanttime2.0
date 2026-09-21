
extends State_base

var timer := 0.5


func start() -> void:
	timer = 0.5


func on_physics_process(delta: float) -> void:
	timer -= delta

	if timer <= 0:
		controlled_node.velocity.y = -controlled_node.jump_force
		state_machine.change_to("Jump(slime)")
