extends enemy_base



@onready var sprite: Sprite2D = $Sprite2D
@onready var front_ray: RayCast2D = $FrontRay


func _ready() -> void:
	actualizar_direccion()


func _physics_process(delta: float) -> void:
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	# Comprobar si hay una pared delante
	front_ray.force_raycast_update()

	if front_ray.is_colliding():
		direction *= -1
		actualizar_direccion()

	# Movimiento horizontal de patrulla
	velocity.x = direction * speed

	move_and_slide()


func actualizar_direccion() -> void:
	# Orientar el RayCast hacia donde camina
	front_ray.target_position.x = abs(front_ray.target_position.x) * direction
	front_ray.force_raycast_update()

	# El sprite original mira a la izquierda
	sprite.flip_h = direction > 0


func _on_area_2d_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
