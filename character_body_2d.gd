extends CharacterBody2D

@export var speed := 120.0
@export var acceleration := 300.0

var player: Node2D = null
var player_in_chase_zone := false
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
			if player and player_in_chase_zone:

				var direction = (
					player.global_position - global_position
				).normalized()

				velocity = velocity.move_toward(
					direction * speed,
					acceleration * delta
				)
			else:
				state = State.RETURN

		State.RETURN:

			var distance = global_position.distance_to(
				origin_position
			)

			if distance > 5:

				var direction = (
					origin_position - global_position
				).normalized()

				velocity = velocity.move_toward(
					direction * speed,
					acceleration * delta
				)

			else:
				global_position = origin_position
				velocity = Vector2.ZERO
				state = State.IDLE

	move_and_slide()


func _on_detection_area_body_entered(body):

	if body.name == "Player" and player_in_chase_zone:

		player = body
		state = State.CHASE


func _on_detection_area_body_exited(body):
	pass
