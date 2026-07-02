extends State_base

var default_recoil
var default_damage
var default_knockback

var hit_done := false


func start():
	print("ENTRÉ A ATTACKR")
	hit_done = false
	controlled_node.can_attack = false
	controlled_node.velocity.x = 0
	default_damage = controlled_node.damage
	default_knockback = controlled_node.knockback
	controlled_node.animated_sprite_2d.play(
		controlled_node.animations["AttackR"]
	)
	default_recoil=controlled_node.knockback
	default_damage=controlled_node.damage

func on_physics_process(_delta):
	print(
	"Anim:", controlled_node.animated_sprite_2d.animation,
	" Frame:", controlled_node.animated_sprite_2d.frame,
	" Playing:", controlled_node.animated_sprite_2d.is_playing()
	)
	if controlled_node.animated_sprite_2d.frame == 3 and !hit_done:
		hit_done = true
		controlled_node.knockback=controlled_node.r_knockback
		controlled_node.damage=controlled_node.r_damage
		print(controlled_node.r_damage)
		controlled_node.attack_collision.disabled = false
	
	if hit_done and controlled_node.animated_sprite_2d.frame > 3:
		controlled_node.attack_collision.disabled = true
	
	if !controlled_node.animated_sprite_2d.is_playing():
		controlled_node.attack_collision.disabled = true
		controlled_node.damage = default_damage
		controlled_node.knockback = default_knockback
		state_machine.change_to("Walk")
		await get_tree().create_timer(controlled_node.attack_cooldown).timeout
		controlled_node.can_attack = true
