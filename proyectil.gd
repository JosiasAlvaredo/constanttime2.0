extends Stats

@export var explosion_scene: PackedScene
@export var rock_scene: PackedScene

var shoot_direction = Vector2.ZERO

func _process(delta):
	position += shoot_direction * speed * delta

func set_shoot_direction(dir):
	shoot_direction = dir.normalized()

func explosion(hit_position: Vector2):
	var parent = get_parent()

	if explosion_scene:
		var new_explosion = explosion_scene.instantiate()
		parent.add_child(new_explosion)
		new_explosion.global_position = hit_position

	if rock_scene:
		var new_rock = rock_scene.instantiate()
		parent.add_child(new_rock)
		new_rock.global_position = hit_position

	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	explosion(global_position)

func _on_area_body_entered(body: Node2D) -> void:
	explosion(global_position)
