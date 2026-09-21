
extends enemy_base


@export var max_distance := 600.0
@export var wave_amplitude := 25.0
@export var wave_frequency := 8.0

var directionPlayer := Vector2.ZERO
var distance_traveled := 0.0
var wave_time := 0.0


func _physics_process(delta: float) -> void:
	var movement: Vector2 = directionPlayer * speed * delta

	wave_time += delta
	distance_traveled += movement.length()

	var perpendicular: Vector2 = Vector2(
		-directionPlayer.y,
		directionPlayer.x
	)

	var wave_offset: Vector2 = perpendicular * sin(
		wave_time * wave_frequency
	) * wave_amplitude

	velocity = movement / delta + wave_offset

	move_and_slide()

	if distance_traveled >= max_distance:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		queue_free()
