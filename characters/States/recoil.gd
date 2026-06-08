extends State_base

func start():
	controlled_node.can_jump=false
	controlled_node.animated_sprite_2d.play("Jump")
	controlled_node.velocity.y=controlled_node.Jump_stength * (1/2**0.5)
	controlled_node.velocity.x*=controlled_node.Jump_stength * (1/2**0.5)


func on_physics_process(delta: float) -> void:
	await get_tree().create_timer(0.75).timeout
	state_machine.change_to("Idle")
