extends State_base
var default_recoil
var default_damage

func start():
	controlled_node.animated_sprite_2d.play(controlled_node.animations["short_sword"])
	default_recoil=controlled_node.knockback
	default_damage=controlled_node.damage
	
func on_physics_process(delta):
	if controlled_node.animated_sprite_2d.frame==2:
		controlled_node.knockback=controlled_node.short_sword_knockback
		controlled_node.damage=controlled_node.short_sword_damage
		controlled_node.collision_short_sword.disabled=false

	if not controlled_node.animated_sprite_2d.is_playing():
		controlled_node.knockback=default_recoil
		controlled_node.damage=default_damage
		controlled_node.collision_short_sword.disabled=true
		state_machine.change_to("Idle_vartime")
