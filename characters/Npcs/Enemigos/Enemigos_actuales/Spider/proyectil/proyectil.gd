extends enemy_base


@export var time_alive := 5.0

var direcionP: Vector2 = Vector2.ZERO


func _ready() -> void:
	await get_tree().create_timer(time_alive).timeout

	if is_inside_tree():
		queue_free()


func _physics_process(delta: float) -> void:

	velocity = direcionP * speed

	move_and_slide()
