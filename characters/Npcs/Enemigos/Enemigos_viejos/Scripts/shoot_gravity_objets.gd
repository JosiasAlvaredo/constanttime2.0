extends State_base
var shooting=false

func on_physics_process(delta: float) -> void:
	if not shooting:
		shooting=true
		await get_tree().create_timer(0.5).timeout
		controlled_node.eye_ray.target_position=controlled_node.player.position-controlled_node.position
		controlled_node.Flip_to(controlled_node.player)
		await get_tree().create_timer(0.2).timeout
		if controlled_node.eye_ray.get_collider()==controlled_node.player:
			var direction=controlled_node.direction
			var bomb=load("res://objets/weapons_tools/Bomb.tscn").instantiate()
			var word=controlled_node.get_parent()
			
			var V0=controlled_node.shoot_velocity
			var target_pocition=controlled_node.player.global_position
			var init_position=controlled_node.create_bomb.global_position
			var gravity:float= ProjectSettings.get_setting("physics/2d/default_gravity")
			
			var dx = target_pocition.x - init_position.x
			var dy = init_position.y - target_pocition.y

			var v2 = V0 * V0

			var discriminant = v2*v2 - gravity*(gravity*dx*dx + 2*dy*v2)


			var angle = atan(
				(v2 - sqrt(discriminant))
				/ (gravity * dx)
			)

			bomb.velocity = Vector2(
				cos(angle)*direction,
				-sin(angle)*direction
			) * V0

			bomb.global_position=init_position
			
			word.add_child(bomb)
			controlled_node.velocity=-bomb.velocity*0.25
			await get_tree().create_timer(0.25).timeout
			controlled_node.velocity=Vector2.ZERO
		shooting=false
