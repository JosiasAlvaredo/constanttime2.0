extends Stats

func _ready() -> void:
	print("hola")
	await get_tree().create_timer(0.5).timeout
	queue_free()
