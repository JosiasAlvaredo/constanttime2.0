extends Node2D


# ============================================================
# CONFIGURACIÓN
# ============================================================

const MODULES_TO_GENERATE: int = 15

# Probabilidad aproximada de elegir cada tipo.
const ROOM_WEIGHT: int = 10
const CORRIDOR_H_WEIGHT: int = 3
const CORRIDOR_V_WEIGHT: int = 2
const TREASURE_WEIGHT: int = 5


# ============================================================
# MÓDULOS
# ============================================================

const ROOM_MODULES: Array[PackedScene] = [
	preload("res://scenes/pruebas mazmorra/modules/rooms/normal/room_01.tscn"),
	preload("res://scenes/pruebas mazmorra/modules/rooms/normal/room_02.tscn"),
	preload("res://scenes/pruebas mazmorra/modules/rooms/normal/room_03.tscn")
]


const CORRIDOR_H_MODULES: Array[PackedScene] = [
	preload("res://scenes/pruebas mazmorra/modules/corridors/horizontal/corridorH_01.tscn")
]


const CORRIDOR_V_MODULES: Array[PackedScene] = [
	preload("res://scenes/pruebas mazmorra/modules/corridors/vertical/corridorV_01.tscn")
]


const TREASURE_MODULES: Array[PackedScene] = [
	preload("res://scenes/pruebas mazmorra/modules/treasure/treasure_01.tscn"),
	preload("res://scenes/pruebas mazmorra/modules/treasure/treasure_02.tscn")
]


const BOSS_MODULES: Array[PackedScene] = [
	preload("res://scenes/pruebas mazmorra/modules/boss/boss_01.tscn")
]


# ============================================================
# ESCENA
# ============================================================

@onready var dungeon: Node2D = $Dungeon


# ============================================================
# DATOS
# ============================================================

var generated_modules: Array[Node2D] = []

var used_positions: Array[Vector2] = []

var treasure_created: bool = false


# ============================================================
# INICIO
# ============================================================

func _ready():

	randomize()

	generate_dungeon()


# ============================================================
# GENERAR MAZMORRA
# ============================================================

func generate_dungeon():

	clear_dungeon()

	# --------------------------------------------------------
	# SALA INICIAL
	# --------------------------------------------------------

	var start: Node2D = ROOM_MODULES[0].instantiate()

	dungeon.add_child(start)

	start.position = Vector2.ZERO

	generated_modules.append(start)

	print("START creada")


	# --------------------------------------------------------
	# PRIMERA SALIDA
	# --------------------------------------------------------

	var current_socket: Marker2D = get_socket(
		start,
		"SocketRight"
	)

	if current_socket == null:

		push_error(
			"Room_01 no tiene SocketRight."
		)

		return


	# --------------------------------------------------------
	# GENERACIÓN
	# --------------------------------------------------------

	for i in range(MODULES_TO_GENERATE):

		var result = create_next_module(
			current_socket
		)

		if result.is_empty():

			print("No se pudo continuar la generación.")

			break


		var new_module: Node2D = result["module"]

		var next_socket: Marker2D = result["socket"]


		if new_module == null:

			break


		# El siguiente módulo continúa desde
		# una de sus salidas.

		current_socket = next_socket


	# --------------------------------------------------------
	# BOSS
	# --------------------------------------------------------

	create_boss(current_socket)


# ============================================================
# CREAR SIGUIENTE MÓDULO
# ============================================================

func create_next_module(
	connection_socket: Marker2D
) -> Dictionary:

	var direction := get_socket_direction(
		connection_socket
	)

	var candidates: Array[Dictionary] = []


	# ========================================================
	# BUSCAR MÓDULOS COMPATIBLES
	# ========================================================

	# --------------------------------------------------------
	# HACIA LA DERECHA
	# --------------------------------------------------------

	if direction == "right":

		for scene in ROOM_MODULES:

			candidates.append({
				"scene": scene,
				"input": "SocketLeft"
			})


		for scene in CORRIDOR_H_MODULES:

			candidates.append({
				"scene": scene,
				"input": "SocketLeft"
			})


	# --------------------------------------------------------
	# HACIA LA IZQUIERDA
	# --------------------------------------------------------

	elif direction == "left":

		for scene in ROOM_MODULES:

			candidates.append({
				"scene": scene,
				"input": "SocketRight"
			})


		for scene in CORRIDOR_H_MODULES:

			candidates.append({
				"scene": scene,
				"input": "SocketRight"
			})


	# --------------------------------------------------------
	# HACIA ABAJO
	# --------------------------------------------------------

	elif direction == "down":

		for scene in ROOM_MODULES:

			candidates.append({
				"scene": scene,
				"input": "SocketUp"
			})


		for scene in CORRIDOR_V_MODULES:

			candidates.append({
				"scene": scene,
				"input": "SocketUp"
			})


		for scene in TREASURE_MODULES:

			if not treasure_created:

				candidates.append({
					"scene": scene,
					"input": "SocketUp"
				})


	# --------------------------------------------------------
	# HACIA ARRIBA
	# --------------------------------------------------------

	elif direction == "up":

		for scene in ROOM_MODULES:

			candidates.append({
				"scene": scene,
				"input": "SocketDown"
			})


		for scene in CORRIDOR_V_MODULES:

			candidates.append({
				"scene": scene,
				"input": "SocketDown"
			})


	# ========================================================
	# NO HAY MÓDULOS
	# ========================================================

	if candidates.is_empty():

		return {}


	# ========================================================
	# ELEGIR MÓDULO
	# ========================================================

	var candidate: Dictionary = candidates.pick_random()

	var scene: PackedScene = candidate["scene"]

	var input_name: String = candidate["input"]


	# ========================================================
	# INSTANCIAR
	# ========================================================

	var module: Node2D = scene.instantiate()

	dungeon.add_child(module)


	# ========================================================
	# BUSCAR SOCKET DE ENTRADA
	# ========================================================

	var input_socket: Marker2D = get_socket(
		module,
		input_name
	)

	if input_socket == null:

		module.queue_free()

		return {}


	# ========================================================
	# CONECTAR SOCKETS
	# ========================================================

	var offset: Vector2 = (
		connection_socket.global_position
		- input_socket.global_position
	)

	module.global_position += offset


	# ========================================================
	# TESORO
	# ========================================================

	if module.scene_file_path.contains("treasure"):

		treasure_created = true


	# ========================================================
	# GUARDAR
	# ========================================================

	generated_modules.append(module)


	print(
		"Nuevo módulo: ",
		module.name,
		" | Dirección: ",
		direction
	)


	# ========================================================
	# BUSCAR UNA SALIDA PARA CONTINUAR
	# ========================================================

	var next_socket := choose_next_socket(
		module,
		input_name
	)


	return {
		"module": module,
		"socket": next_socket
	}


# ============================================================
# ELEGIR SIGUIENTE SOCKET
# ============================================================

func choose_next_socket(
	module: Node2D,
	input_socket_name: String
) -> Marker2D:

	var sockets: Array[Marker2D] = []


	for child in module.get_children():

		if child is Marker2D:

			var socket: Marker2D = child

			if socket.name != input_socket_name:

				sockets.append(socket)


	if sockets.is_empty():

		return null


	# --------------------------------------------------------
	# Prioridad horizontal
	# --------------------------------------------------------

	var horizontal: Array[Marker2D] = []

	for socket in sockets:

		if (
			socket.name == "SocketRight"
			or socket.name == "SocketLeft"
		):

			horizontal.append(socket)


	if not horizontal.is_empty():

		# 70% de las veces continuamos horizontalmente.

		if randf() < 0.7:

			return horizontal.pick_random()


	# --------------------------------------------------------
	# Cualquier salida
	# --------------------------------------------------------

	return sockets.pick_random()


# ============================================================
# OBTENER SOCKET
# ============================================================

func get_socket(
	module: Node2D,
	socket_name: String
) -> Marker2D:

	return module.get_node_or_null(
		socket_name
	) as Marker2D


# DETERMINAR DIRECCIÓN

func get_socket_direction(
	socket: Marker2D
) -> String:

	match socket.name:

		"SocketRight":
			return "right"

		"SocketLeft":
			return "left"

		"SocketUp":
			return "up"

		"SocketDown":
			return "down"


	return ""


# CREAR BOSS

func create_boss(
	connection_socket: Marker2D
):

	if connection_socket == null:

		return


	# --------------------------------------------------------
	# Elegir Boss
	# --------------------------------------------------------

	var boss_scene: PackedScene = (
		BOSS_MODULES.pick_random()
	)

	var boss: Node2D = boss_scene.instantiate()

	dungeon.add_child(boss)


	# Boss entra por SocketLeft

	var boss_socket: Marker2D = get_socket(
		boss,
		"SocketLeft"
	)


	if boss_socket == null:

		push_error(
			"El Boss necesita un SocketLeft."
		)
		boss.queue_free()
		return

	# Conectar

	var offset: Vector2 = (
		connection_socket.global_position
		- boss_socket.global_position
	)

	boss.global_position += offset


	print("BOSS creado")


# LIMPIAR

func clear_dungeon():

	for child in dungeon.get_children():

		child.queue_free()


	generated_modules.clear()

	used_positions.clear()

	treasure_created = false
