extends CharacterBody2D

@export var speed := 200.0
@export var max_distance := 500.0

var direction := Vector2.ZERO
var distance_traveled := 0.0


func _physics_process(delta: float) -> void:
	var movement := direction * speed * delta
	
	position += movement
	distance_traveled += movement.length()
	
	if distance_traveled >= max_distance:
		queue_free()
