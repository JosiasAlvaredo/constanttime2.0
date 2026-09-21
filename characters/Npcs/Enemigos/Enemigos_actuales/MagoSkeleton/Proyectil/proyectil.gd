
extends enemy_base

@export var max_distance := 600.0

var directionPlayer := Vector2.ZERO
var distance_traveled := 0.0


func _physics_process(delta: float) -> void:
	var movement: Vector2 = directionPlayer * speed * delta

	velocity = directionPlayer * speed
	move_and_slide()

	distance_traveled += movement.length()

	if distance_traveled >= max_distance:
		queue_free()
