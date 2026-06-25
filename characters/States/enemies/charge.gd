extends State_base
var direction=0
var local_speed=0
func start():
	direction=controlled_node.direction
	var origin_knockback=controlled_node.knockback
	controlled_node.knockback=Vector2(-100,-100)
	local_speed=-10
	await get_tree().create_timer(0.5).timeout
	controlled_node.Knockback_resistence=0
	controlled_node.knockback=Vector2(-600,-100)
	local_speed=800
	await get_tree().create_timer(0.125).timeout
	controlled_node.knockback=origin_knockback
	controlled_node.Knockback_resistence=1
	local_speed=0
	await get_tree().create_timer(1).timeout
	state_machine.change_to("Move")
	
func on_physics_process(delta: float) -> void:
	controlled_node.velocity.x=direction*local_speed
