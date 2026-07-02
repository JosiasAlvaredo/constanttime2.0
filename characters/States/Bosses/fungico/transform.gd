extends State_base

func start():
	print("Recibiendo señal1")
	controlled_node.velocity = Vector2.ZERO
	controlled_node.animated_sprite_2d.play(controlled_node.animations["Transform"])

func on_physics_process(delta):
	if !controlled_node.animated_sprite_2d.is_playing():
		print("CAMBIANDO A WALK")
		state_machine.change_to("Walk")
