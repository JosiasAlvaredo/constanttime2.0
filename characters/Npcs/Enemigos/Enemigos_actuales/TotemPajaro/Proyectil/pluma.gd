extends Area2D

@export var speed := 200.0
@export var max_distance := 500.0

var direction := 1
var distance_traveled := 0.0


func _physics_process(delta):
	var movement = speed * delta
	
	position.y += movement * direction
	distance_traveled += movement
	
	if distance_traveled >= max_distance:
		queue_free()


func _on_body_entered(body):
	if body.is_in_group("player"):
		queue_free()
