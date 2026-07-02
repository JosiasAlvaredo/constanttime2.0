extends State_base

var summoned := false

func start():
	summoned = false
	controlled_node.velocity.x = 0
	controlled_node.vulnerable = true
	controlled_node.animated_sprite_2d.play(
	controlled_node.animations["AttackL"]
	)


func on_physics_process(delta):
	if controlled_node.animated_sprite_2d.frame == 4 and !summoned:
		summoned = true
		controlled_node.spawn_funfi_flour()
		
	if !controlled_node.animated_sprite_2d.is_playing():
		controlled_node.vulnerable = false
		state_machine.change_to("Walk")
