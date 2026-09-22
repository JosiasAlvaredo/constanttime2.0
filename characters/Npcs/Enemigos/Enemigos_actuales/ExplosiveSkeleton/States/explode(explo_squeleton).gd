extends State_base

@export var explosion_time: float = 0.15

func start() -> void:
	controlled_node.animation_player.play("RESET")
	controlled_node.sprite.play("explote")
	controlled_node.velocity = Vector2.ZERO

	var player = controlled_node.player

	if player != null and is_instance_valid(player):
		if player.has_method("take_damage"):
			player.take_damage(controlled_node.damage)

	await get_tree().create_timer(float(1)).timeout
	controlled_node.explote_area.set_collision_layer_value(3,true)
	await get_tree().create_timer(float(4.0/7.0)).timeout
	if is_instance_valid(controlled_node):
		controlled_node.queue_free()
