extends enemy_base

@export var move_speed := 120.0
@export var acceleration := 300.0

var origin_position: Vector2

enum State {
	IDLE,
	CHASE,
	RETURN
}

var state := State.IDLE


func _ready():
	origin_position = global_position


func _physics_process(delta):

	match state:

		State.IDLE:
			velocity = velocity.move_toward(
				Vector2.ZERO,
				acceleration * delta
			)

		State.CHASE:

			if player:

				var move_direction = (player.global_position - global_position).normalized()

				velocity = velocity.move_toward(
					move_direction * move_speed,
					acceleration * delta
				)

			else:
				state = State.RETURN

		State.RETURN:

			if global_position.distance_to(origin_position) > 5:

				var move_direction = (origin_position - global_position).normalized()

				velocity = velocity.move_toward(
					move_direction * move_speed,
					acceleration * delta
				)

			else:
				global_position = origin_position
				velocity = Vector2.ZERO
				state = State.IDLE

	move_and_slide()


func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		state = State.CHASE


func _on_detection_area_body_exited(body):
	if body == player:
		player = null
		state = State.RETURN


func _on_daño_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
