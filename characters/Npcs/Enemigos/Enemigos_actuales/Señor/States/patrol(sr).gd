extends State_base


func start() -> void:
	print("ENTRO A PATROL")
	controlled_node.animated_sprite_2d.play("move")

func on_physics_process(delta: float) -> void:
	var enemy = controlled_node

	# Movimiento
	enemy.velocity.x = enemy.direction * enemy.speed

	# Detectar pared
	if enemy.wall_ray.is_colliding():
		enemy.change_direction()
		return

	# Detectar precipicio
	if not enemy.floor_ray.is_colliding():
		enemy.change_direction()
		return


	enemy.move_and_slide()
