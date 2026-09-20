extends enemy_base

@export var max_distance := 600.0
var start_position := Vector2.ZERO

func _ready():
	start_position = global_position



func _physics_process(delta):
	position += direction * speed * delta

	if global_position.distance_to(start_position) >= max_distance:
		queue_free()
