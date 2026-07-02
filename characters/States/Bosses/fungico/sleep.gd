extends State_base

func start():
	controlled_node.velocity = Vector2.ZERO
	controlled_node.animated_sprite_2d.play(
		controlled_node.animations["Petrified"]
	)

func on_physics_process(delta):
	controlled_node.velocity.x = 0
