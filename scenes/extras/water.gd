extends Node2D


# ============================================================
# TAMAÑO DEL AGUA
# ============================================================

@export_category("Tamaño")

@export var water_width: float = 340.0
@export var water_height: float = 60.0


# ============================================================
# RESORTES
# ============================================================

@export_category("Resortes")

@export_range(8, 100, 1)
var spring_count: int = 35

@export var stiffness: float = 0.020
@export var damping: float = 0.035


# ============================================================
# PROPAGACIÓN
# ============================================================

@export_category("Ondas")

@export var spread: float = 0.20

@export_range(1, 15, 1)
var spread_iterations: int = 8


# ============================================================
# LIMITES
# ============================================================

@export_category("Limites de la superficie")

## Cuánto puede subir el agua.
@export var max_wave_height: float = 10.0

## Cuánto puede bajar el agua.
@export var max_wave_depth: float = 15.0


# ============================================================
# SPLASH
# ============================================================

@export_category("Splash")

## Fuerza de un impacto normal.
@export var splash_force: float = -80.0

## Radio del impacto.
@export_range(1, 10, 1)
var splash_radius: int = 3


# ============================================================
# VISUAL
# ============================================================

@export_category("Visual")

@export var water_color: Color = Color(0.08, 0.40, 0.75, 0.70)

@export var surface_color: Color = Color(0.20, 0.65, 1.0, 1.0)

@export var surface_width: float = 2.0


# ============================================================
# DATOS DE LOS RESORTES
# ============================================================

var heights: Array[float] = []
var velocities: Array[float] = []
var accelerations: Array[float] = []


# ============================================================
# INICIALIZACIÓN
# ============================================================

func _ready() -> void:
	initialize_springs()
	setup_collision()

	queue_redraw()


func initialize_springs() -> void:
	heights.clear()
	velocities.clear()
	accelerations.clear()

	for i in range(spring_count):
		heights.append(0.0)
		velocities.append(0.0)
		accelerations.append(0.0)


# ============================================================
# COLISIÓN
# ============================================================

func setup_collision() -> void:

	var collision_shape: CollisionShape2D = $Area2D2/CollisionShape2D

	var rectangle := RectangleShape2D.new()

	rectangle.size = Vector2(
		water_width,
		water_height
	)

	collision_shape.shape = rectangle

	# IMPORTANTE:
	# La superficie del agua está en Y = 0.
	# Por eso el centro del CollisionShape está a la mitad
	# de la altura.

	collision_shape.position = Vector2(
		water_width / 2.0,
		water_height / 2.0
	)


# ============================================================
# FÍSICA
# ============================================================

func _physics_process(delta: float) -> void:

	update_springs(delta)

	propagate_waves()

	queue_redraw()


# ============================================================
# ACTUALIZAR RESORTES
# ============================================================

func update_springs(delta: float) -> void:

	for i in range(spring_count):

		var displacement: float = heights[i]

		# Ley de Hooke
		var spring_force: float = -stiffness * displacement

		# Amortiguación
		var damping_force: float = -damping * velocities[i]

		accelerations[i] = (
			spring_force +
			damping_force
		)

		velocities[i] += (
			accelerations[i] *
			delta *
			60.0
		)

		heights[i] += (
			velocities[i] *
			delta *
			60.0
		)

		# LIMITAR EL MOVIMIENTO

		heights[i] = clamp(
			heights[i],
			-max_wave_height,
			max_wave_depth
		)

		# Si llega al límite superior.
		if heights[i] <= -max_wave_height:
			velocities[i] *= 0.25

		# Si llega al límite inferior.
		if heights[i] >= max_wave_depth:
			velocities[i] *= 0.25


# ============================================================
# PROPAGACIÓN
# ============================================================

func propagate_waves() -> void:

	for iteration in range(spread_iterations):

		var left_deltas: Array[float] = []
		var right_deltas: Array[float] = []

		left_deltas.resize(spring_count)
		right_deltas.resize(spring_count)

		for i in range(spring_count):

			left_deltas[i] = 0.0
			right_deltas[i] = 0.0

			if i > 0:

				left_deltas[i] = (
					heights[i] -
					heights[i - 1]
				) * spread

			if i < spring_count - 1:

				right_deltas[i] = (
					heights[i] -
					heights[i + 1]
				) * spread


		for i in range(spring_count):

			if i > 0:
				velocities[i - 1] += left_deltas[i]

			if i < spring_count - 1:
				velocities[i + 1] += right_deltas[i]


# ============================================================
# SPLASH
# ============================================================

func splash_at_position(
	x_position: float,
	force: float
) -> void:

	var spacing: float = get_spring_spacing()

	var center_index: int = roundi(
		x_position / spacing
	)

	center_index = clamp(
		center_index,
		0,
		spring_count - 1
	)


	for offset in range(
		-splash_radius,
		splash_radius + 1
	):

		var index: int = (
			center_index +
			offset
		)

		if index < 0:
			continue

		if index >= spring_count:
			continue


		var distance: float = abs(
			float(offset)
		)

		var influence: float = 1.0 - (
			distance /
			float(splash_radius + 1)
		)


		velocities[index] += (
			force *
			influence
		)


# ============================================================
# DISTANCIA ENTRE RESORTES
# ============================================================

func get_spring_spacing() -> float:

	if spring_count <= 1:
		return water_width

	return water_width / float(
		spring_count - 1
	)


# ============================================================
# SUPERFICIE
# ============================================================

func get_surface_points() -> PackedVector2Array:

	var points := PackedVector2Array()

	var spacing: float = get_spring_spacing()

	for i in range(spring_count):

		var x: float = (
			float(i) *
			spacing
		)

		var y: float = heights[i]

		points.append(
			Vector2(x, y)
		)

	return points


# ============================================================
# DIBUJAR AGUA
# ============================================================

func _draw() -> void:

	if spring_count <= 1:
		return


	var surface: PackedVector2Array = (
		get_surface_points()
	)


	# ========================================================
	# POLÍGONO DEL AGUA
	# ========================================================

	var water_polygon := PackedVector2Array()


	# Superficie.
	for point in surface:

		water_polygon.append(point)


	# Esquina inferior derecha.
	water_polygon.append(
		Vector2(
			water_width,
			water_height
		)
	)


	# Esquina inferior izquierda.
	water_polygon.append(
		Vector2(
			0.0,
			water_height
		)
	)


	draw_colored_polygon(
		water_polygon,
		water_color
	)


	# ========================================================
	# LÍNEA DE SUPERFICIE
	# ========================================================

	draw_polyline(
		surface,
		surface_color,
		surface_width,
		true
	)


# ============================================================
# OBJETO FÍSICO ENTRA AL AGUA
# ============================================================

func _on_area_2d_2_body_entered(body: Node2D) -> void:

	var local_position: Vector2 = (
		to_local(body.global_position)
	)

	splash_at_position(
		local_position.x,
		splash_force
	)


# ============================================================
# AREA2D ENTRA AL AGUA
# ============================================================


func _on_area_2d_2_area_entered(area: Area2D) -> void:
	var local_position: Vector2 = (
		to_local(area.global_position)
	)

	splash_at_position(
		local_position.x,
		splash_force
	)
