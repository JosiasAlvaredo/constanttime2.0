extends State_base
func start():
	controlled_node.animated_sprite_2d.play(controlled_node.animations["charge"])

func on_physics_process(delta: float) -> void:
	if not controlled_node.animated_sprite_2d.is_playing():
		controlled_node.animated_sprite_2d.play(controlled_node.animations["attack"])
		controlled_node.hitbox_collition.disabled=false
		await get_tree().create_timer(0.75).timeout
		controlled_node.hitbox_collition.disabled=true
		state_machine.change_to("Idle")
