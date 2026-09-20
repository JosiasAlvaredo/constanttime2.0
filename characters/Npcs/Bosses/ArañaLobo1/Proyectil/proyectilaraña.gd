extends enemy_base



@export var max_distance := 600.0

var direcionP := Vector2.ZERO
var start_position := Vector2.ZERO


func _ready() -> void:
	start_position = global_position


func _physics_process(delta: float) -> void:
	global_position += direcionP * speed * delta

	if global_position.distance_to(start_position) >= max_distance:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	print("PROYECTIL DETECTO: ", area.name)

	if area.get_parent().is_in_group("player"):
		print("ERA EL PLAYER")
		queue_free()
