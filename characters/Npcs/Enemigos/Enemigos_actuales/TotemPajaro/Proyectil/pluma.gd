extends Area2D

@export var speed := 300.0
@export var max_distance := 600.0
@export var wave_amplitude := 25.0
@export var wave_frequency := 8.0

var direction := Vector2.ZERO
var distance_traveled := 0.0
var wave_time := 0.0


func _physics_process(delta):
	var movement = direction * speed * delta

	wave_time += delta
	distance_traveled += movement.length()

	var perpendicular = Vector2(-direction.y, direction.x)
	var wave_offset = perpendicular * sin(wave_time * wave_frequency) * wave_amplitude

	position += movement + wave_offset * delta

	if distance_traveled >= max_distance:
		queue_free()


func _on_body_entered(body):
	if body.is_in_group("player"):
		queue_free()
