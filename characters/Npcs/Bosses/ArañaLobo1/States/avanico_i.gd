
extends State_base

var boss

@export var projectile_scene: PackedScene

@export var cantidad_proyectiles := 7
@export var separacion_angulo := 15.0
@export var tiempo_entre_disparos := 0.08

func start() -> void:
	boss = controlled_node

	# La araña permanece quieta
	boss.velocity = Vector2.ZERO

	disparar_abanico()


func disparar_abanico() -> void:
	if projectile_scene == null:
		push_error("AbanicoIzq: no se asignó projectile_scene")
		state_machine.change_to("Idle")
		return

	var shoot_point: Marker2D = boss.get_node("ShootPoint")

	# De izquierda a derecha:
	# -45°, -30°, -15°, 0°, 15°, 30°, 45°
	var angulo_inicial := -((cantidad_proyectiles - 1) * separacion_angulo) / 2.0

	for i in range(cantidad_proyectiles):

		var proyectil = projectile_scene.instantiate()
		get_tree().current_scene.add_child(proyectil)

		proyectil.global_position = shoot_point.global_position

		var angulo := angulo_inicial + (i * separacion_angulo)

		# Vector2.DOWN es la dirección central porque la araña
		# está arriba del jugador y mira hacia abajo.
		var direccion := Vector2.DOWN.rotated(deg_to_rad(angulo))

		proyectil.direcionP = direccion.normalized()

		await get_tree().create_timer(tiempo_entre_disparos).timeout

		if state_machine.current_state != self:
			return

	if state_machine.current_state == self:
		state_machine.change_to("Idle")


func on_physics_process(_delta: float) -> void:
	boss.velocity = Vector2.ZERO


func end() -> void:
	pass
