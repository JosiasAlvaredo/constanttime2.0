extends enemy_base

@export var liana_scene: PackedScene
@export var liana_spacing := 80.0

var playerUbi: Node2D = null


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		playerUbi = body


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == playerUbi:
		playerUbi = null


func spawn_lianas() -> void:
	if playerUbi == null:
		return

	if liana_scene == null:
		return

	var start_position: Vector2 = global_position
	var end_position: Vector2 = playerUbi.global_position

	var distance: float = start_position.distance_to(end_position)

	if distance <= liana_spacing:
		return

	var direction_to_player: Vector2 = (
		end_position - start_position
	).normalized()

	var amount: int = int(distance / liana_spacing)

	for i in range(1, amount + 1):
		var distance_from_enemy: float = i * liana_spacing

		if distance_from_enemy >= distance:
			break

		var liana = liana_scene.instantiate()

		get_tree().current_scene.add_child(liana)

		liana.global_position = (
			start_position
			+ direction_to_player * distance_from_enemy
		)


func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
