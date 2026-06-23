extends State_base
var attaking=false
 

func on_physics_process(delta: float) -> void:
	if not attaking:
		controlled_node.tongue_live=6
		attaking=true
		await get_tree().create_timer(0.5).timeout
		controlled_node.Flip_to(controlled_node.player)
		controlled_node.tongue_ray.target_position = controlled_node.player.position - controlled_node.position
		controlled_node.tongue_ray.force_raycast_update()
		
		if controlled_node.tongue_ray.get_collider()==controlled_node.player:
			var tongue_velocity=controlled_node.tongue_velocity
			var dx=controlled_node.tongue_ray.target_position.x-controlled_node.tongue_ray.position.x
			var dy=controlled_node.tongue_ray.target_position.y-controlled_node.tongue_ray.position.y
			var hit_pos
			
			controlled_node.tongue_to_solid_ray.global_rotation = atan2(dy,dx)
			controlled_node.tongue_to_solid_ray.force_raycast_update()

			if controlled_node.tongue_to_solid_ray.is_colliding():
				hit_pos = controlled_node.tongue_to_solid_ray.get_collision_point()
			else:
				hit_pos = controlled_node.tongue_to_solid_ray.to_global(controlled_node.tongue_to_solid_ray.target_position)
				
			var local_hit = controlled_node.tongue_line.to_local(hit_pos)
			
			controlled_node.tongue_line.clear_points()
			controlled_node.tongue_line.add_point(Vector2.ZERO)
			
			for i in range(50):
				await get_tree().create_timer(tongue_velocity).timeout
				controlled_node.tongue_line.add_point(i*local_hit/50)
			
			await get_tree().create_timer(tongue_velocity*20).timeout
			
			for i in range(50):
				await get_tree().create_timer(tongue_velocity*3).timeout
				controlled_node.tongue_line.remove_point( controlled_node.tongue_line.get_point_count() - 1 )
			controlled_node.tongue_line.clear_points()
		attaking=false
