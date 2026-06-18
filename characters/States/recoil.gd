extends State_base
var recoil_velocity= Vector2(0,0)
func start():

	controlled_node.can_jump=false
	controlled_node.animated_sprite_2d.play(controlled_node.animations["jump"])
	controlled_node.velocity.y*=controlled_node.recoil.y*controlled_node.Knockback_resistence
	controlled_node.velocity.x*=controlled_node.recoil.x*controlled_node.Knockback_resistence
	print(controlled_node.Knockback_resistence)
	if controlled_node.is_on_floor() and sign(controlled_node.velocity.y)==-1:
		controlled_node.velocity.y=-controlled_node.velocity.y
		
		
	recoil_velocity.x=controlled_node.velocity.x
	recoil_velocity.y=controlled_node.velocity.y

func on_physics_process(delta: float) -> void:
	if controlled_node.crouch_ray.is_colliding():
		controlled_node.velocity.y=-recoil_velocity.y
	if controlled_node.is_on_wall():
		controlled_node.velocity.x=-recoil_velocity.x
	if controlled_node.is_on_floor():
		controlled_node.velocity.y=-recoil_velocity.y/2
	
	recoil_velocity.x=controlled_node.velocity.x
	recoil_velocity.y=controlled_node.velocity.y
	if recoil_velocity.x==0 or recoil_velocity.y==0:
		controlled_node.velocity.x/=2
		controlled_node.velocity.y/=2
	await get_tree().create_timer(0.45).timeout
	if state_machine.current_state==self:
		state_machine.change_to("Fall")
