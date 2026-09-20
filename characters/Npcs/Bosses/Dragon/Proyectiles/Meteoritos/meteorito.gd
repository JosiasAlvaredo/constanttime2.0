extends CharacterBody2D

@export var gravity := 400.0
@export var max_fall_speed := 400.0


func _physics_process(delta: float) -> void:

	# Gravedad
	velocity.y += gravity * delta

	# Limitar velocidad de caída
	velocity.y = min(velocity.y, max_fall_speed)

	# Mantener movimiento horizontal
	move_and_slide()

	# Desaparecer al tocar el piso
	if is_on_floor():
		queue_free()
