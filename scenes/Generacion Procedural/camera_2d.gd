extends Camera2D

@export var speed: float = 2000.0
@export var zoom_speed: float = 2.0
@export var zoom_min: float = 0.2
@export var zoom_max: float = 5.0

func _process(delta: float) -> void:
	# Captura las direcciones de movimiento usando el mapa de entrada por defecto
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Aplica el movimiento a la posición de la cámara
	position += input_direction * speed * delta
	
	# Zoom con teclas X (acercar) y Z (alejar)
	if Input.is_key_pressed(KEY_X):
		zoom -= Vector2.ONE * zoom_speed * delta
	if Input.is_key_pressed(KEY_Z):
		zoom += Vector2.ONE * zoom_speed * delta
	
	zoom = zoom.clamp(Vector2(zoom_min, zoom_min), Vector2(zoom_max, zoom_max))
