extends Camera2D

@export var speed: float = 2000.0

func _process(delta: float) -> void:
	# Captura las direcciones de movimiento usando el mapa de entrada por defecto
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Aplica el movimiento a la posición de la cámara
	position += input_direction * speed * delta
