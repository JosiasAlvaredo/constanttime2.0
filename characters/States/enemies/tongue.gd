extends State_base
var attaking=false

func on_physics_process(delta: float) -> void:
	if not attaking:
		attaking=true
		await get_tree().create_timer(0.5).timeout
		controlled_node.tongue_ray.target_position = controlled_node.player.position - controlled_node.position
		controlled_node.tongue_ray.force_raycast_update()
		
		if controlled_node.tongue_ray.get_collider()==controlled_node.player:
			var dx=controlled_node.tongue_ray.target_position.x-controlled_node.tongue_ray.position.x
			var dy=controlled_node.tongue_ray.target_position.y-controlled_node.tongue_ray.position.y
			controlled_node.tongue_to_solid_ray.global_rotation = atan2(dy,dx)
			controlled_node.tongue_to_solid_ray.force_raycast_update()

			var hit_pos

			if controlled_node.tongue_to_solid_ray.is_colliding():
				hit_pos = controlled_node.tongue_to_solid_ray.get_collision_point()
			else:
				hit_pos = controlled_node.tongue_to_solid_ray.to_global(controlled_node.tongue_to_solid_ray.target_position)
				
			var local_hit = controlled_node.tongue_line.to_local(hit_pos)
			
			controlled_node.tongue_line.clear_points()
			controlled_node.tongue_line.add_point(controlled_node.tongue_to_solid_ray.position)
			controlled_node.tongue_line.add_point(local_hit)

			await get_tree().create_timer(0.2).timeout

			controlled_node.tongue_line.clear_points()
		attaking=false
