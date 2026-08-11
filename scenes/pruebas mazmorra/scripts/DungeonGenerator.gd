extends Node2D

# CONFIGURACIÓN
const MODULES_TO_GENERATE: int = 25
const MAX_ATTEMPTS: int = 40

# MÓDULOS
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


# NODO DE LA MAZMORRA
@onready var dungeon: Node2D = $Dungeon


# DATOS DE GENERACIÓN
# Todos los módulos que fueron aceptados.
var generated_modules: Array[Node2D] = []

# Rectángulos ocupados por los módulos.
var occupied_rects: Array[Rect2] = []

# Salidas que todavía pueden utilizarse.
var pending_sockets: Array[Marker2D] = []

# Controla si ya existe una sala de tesoro.
var treasure_created: bool = false

# INICIO
func _ready():
	randomize()
	generate_dungeon()

# GENERAR MAZMORRA
func generate_dungeon():
	clear_dungeon()
	
	# SALA INICIAL
	var start: Node2D = ROOM_MODULES[0].instantiate()
	dungeon.add_child(start)
	start.position = Vector2.ZERO
	generated_modules.append(start)
	register_module(start)
	
	# SOCKET DERECHO DE LA SALA INICIAL
	var start_socket: Marker2D = get_socket(
		start,
		"SocketRight"
	)
	if start_socket == null:
		push_error(
			"Room_01 necesita un SocketRight"
		)
		return
	pending_sockets.append(start_socket)
	
	# GENERACIÓN
	var attempts: int = 0
	while (
		generated_modules.size() < MODULES_TO_GENERATE
		and not pending_sockets.is_empty()
		and attempts < MAX_ATTEMPTS
	):
		attempts += 1
		
		# ELEGIR UNA SALIDA
		var socket_index: int = randi_range(
			0,
			pending_sockets.size() - 1
		)
		
		var socket: Marker2D = pending_sockets[
			socket_index
		]
		
		pending_sockets.remove_at(
			socket_index
		)
		
		# INTENTAR CREAR MÓDULO
		var created: bool = create_from_socket(
			socket
		)
		
		if created:
			print(
				"Módulos: ",
				generated_modules.size(),
				" | Salidas: ",
				pending_sockets.size()
			)
			
	
	# TESORO
	if not treasure_created:
		create_treasure()
	
	# BOSS
	create_boss()
	print("Módulos: ", generated_modules.size())
	print("Salidas restantes: ", pending_sockets.size())

# CREAR MÓDULO DESDE SOCKET
func create_from_socket(connection_socket: Marker2D) -> bool:
	var direction: String = get_socket_direction(
		connection_socket
	)
	
	if direction == "":
		return false
	
	# CANDIDATOS
	var candidates: Array[Dictionary] = []
	
	# DERECHA
	if direction == "right":
		add_candidates(
			candidates,
			ROOM_MODULES,
			"SocketLeft"
		)
		
		add_candidates(
			candidates,
			CORRIDOR_H_MODULES,
			"SocketLeft"
		)
	
	# IZQUIERDA
	elif direction == "left":
		add_candidates(
			candidates,
			ROOM_MODULES,
			"SocketRight"
		)
	
		add_candidates(
			candidates,
			CORRIDOR_H_MODULES,
			"SocketRight"
		)
	
	# ABAJO
	elif direction == "down":
		add_candidates(
			candidates,
			ROOM_MODULES,
			"SocketUp"
		)
	
		add_candidates(
			candidates,
			CORRIDOR_V_MODULES,
			"SocketUp"
		)
	
		if not treasure_created:
			add_candidates(
				candidates,
				TREASURE_MODULES,
				"SocketUp"
			)
	
	# ARRIBA
	elif direction == "up":
		add_candidates(
			candidates,
			ROOM_MODULES,
			"SocketDown"
		)
	
		add_candidates(
			candidates,
			CORRIDOR_V_MODULES,
			"SocketDown"
		)
	
	# NO HAY CANDIDATOS
	if candidates.is_empty():
		return false
	
	# RANDOMIZAR
	candidates.shuffle()
	# PROBAR CANDIDATOS
	for candidate in candidates:
		var scene: PackedScene = candidate["scene"]
		var input_socket_name: String = candidate["input"]
		
		var module: Node2D = scene.instantiate()
		dungeon.add_child(module)
		
		var input_socket: Marker2D = get_socket(
			module,
			input_socket_name
		)
	
		if input_socket == null:
			push_warning(
				module.name
				+ " no tiene "
				+ input_socket_name
			)
			module.queue_free()
			continue
		
		align_module(
			module,
			input_socket,
			connection_socket
		)
	
		if module_overlaps(module):
			module.queue_free()
			continue
		
		generated_modules.append(module)
		register_module(module)
		
		if is_treasure(module):
			treasure_created = true
		
		add_next_sockets(
			module,
			input_socket_name
		)
		
		print(
			"CREADO: ",
			module.name,
			" | entrada: ",
			input_socket_name
		)
		
		return true
	return false
	
func add_candidates(candidates: Array[Dictionary], scenes: Array[PackedScene], input_socket: String):
	for scene in scenes:
		candidates.append({
			"scene": scene,
			"input": input_socket
		})

func align_module(module: Node2D, module_socket: Marker2D, target_socket: Marker2D):
	var offset: Vector2 = (
		target_socket.global_position
		- module_socket.global_position
	)
	module.global_position += offset

func add_next_sockets(module: Node2D, used_socket: String):
	if is_horizontal_corridor(module):
		add_horizontal_corridor_output(
			module,
			used_socket
		)
		return
	
	if is_vertical_corridor(module):
		add_vertical_corridor_output(
			module,
			used_socket
		)
		return
	
	for child in module.get_children():
		if not child is Marker2D:
			continue
			
		var socket: Marker2D = child as Marker2D
		
		if socket.name == used_socket:
			continue
		
		pending_sockets.append(socket)
	

func add_horizontal_corridor_output(module: Node2D, used_socket: String):
	if used_socket == "SocketLeft":
		var output: Marker2D = get_socket(
			module,
			"SocketRight"
		)
		
		if output != null:
			pending_sockets.append(output)
			
	elif used_socket == "SocketRight":
		var output: Marker2D = get_socket(
			module,
			"SocketLeft"
		)
		
		if output != null:
			pending_sockets.append(output)
	
	var down: Marker2D = get_socket(
		module,
		"SocketDown"
	)
	if down != null:
		pending_sockets.append(down)
	

func add_vertical_corridor_output(module: Node2D, used_socket: String):
	if used_socket == "SocketUp":
		var output: Marker2D = get_socket(
			module,
			"SocketDown"
		)
	
		if output != null:
			pending_sockets.append(output)
		
	elif used_socket == "SocketDown":
		var output: Marker2D = get_socket(
			module,
			"SocketUp"
		)
		
		if output != null:
			pending_sockets.append(output)
			
		
	

func module_overlaps(module: Node2D) -> bool:
	var new_rect: Rect2 = get_module_rect(
		module
	)
	
	if new_rect.size == Vector2.ZERO:
		push_error(
			module.name
			+ " tiene un Bounds inválido"
		)
		return true
	for existing_rect in occupied_rects:
		var expanded_rect: Rect2 = existing_rect.grow(2.0)
		
		if new_rect.intersects(
			expanded_rect,
			false
		):
			return true
	return false

func get_module_rect(module: Node2D) -> Rect2:
	var bounds: CollisionShape2D = (
		module.get_node_or_null(
			"Bounds/CollisionShape2D"
		)
		as CollisionShape2D
	)
	
	if bounds == null:
		push_error(module.name + " no tiene Bounds/CollisionShape2D")
		return Rect2()
		
	var shape: Shape2D = bounds.shape
	
	if shape == null:
		push_error(
			module.name
			+ " tiene un CollisionShape2D sin Shape2D"
		)
		return Rect2()
	if shape is RectangleShape2D:
		var rectangle: RectangleShape2D = (
			shape as RectangleShape2D
		)
		var size: Vector2 = rectangle.size
		return Rect2(
			bounds.global_position - size / 2.0,
			size
		)
	
	push_error(
		module.name
		+ " necesita un RectangleShape2D"
	)
	
	return Rect2()

func register_module(module: Node2D):
	var rect: Rect2 = get_module_rect(
		module
	)
	occupied_rects.append(
		rect
	)

func get_socket(module: Node2D, socket_name: String) -> Marker2D:
	return module.get_node_or_null(
		socket_name
	) as Marker2D

func get_socket_direction(socket: Marker2D) -> String:
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

func is_horizontal_corridor(module: Node2D) -> bool:
	return module.scene_file_path.contains(
		"/corridors/horizontal/"
	)

func is_vertical_corridor(module: Node2D) -> bool:
	return module.scene_file_path.contains(
		"/corridors/vertical/"
	)

func is_treasure(module: Node2D) -> bool:
	return module.scene_file_path.contains(
		"/treasure/"
	)

func create_treasure():
	if treasure_created:
		return
	if pending_sockets.is_empty():
		return
	var sockets: Array[Marker2D] = pending_sockets.duplicate()
	sockets.shuffle()
	for connection_socket in sockets:
		var scene: PackedScene = (
			TREASURE_MODULES.pick_random()
		)
		
		var treasure: Node2D = scene.instantiate()
		dungeon.add_child(treasure)
		
		var direction: String = (
			get_socket_direction(
				connection_socket
			)
		)
		var input_name: String = ""
		match direction:
			"right":
				input_name = "SocketLeft"
			"left":
				input_name = "SocketRight"
			"down":
				input_name = "SocketUp"
			"up":
				input_name = "SocketDown"
		
		var input_socket: Marker2D = get_socket(
			treasure,
			input_name
		)
		
		if input_socket == null:
			treasure.queue_free()
			continue
		
		align_module(
			treasure,
			input_socket,
			connection_socket
		)
		
		if module_overlaps(treasure):
			treasure.queue_free()
			continue
			
		generated_modules.append(
			treasure
		)
		
		register_module(
			treasure
		)
		
		treasure_created = true
		print("TESORO creado")
		return

func create_boss():
	if pending_sockets.is_empty():
		print("No hay salida disponible para Boss")
		return
		
	var sockets: Array[Marker2D] = (
		pending_sockets.duplicate()
	)
	
	sockets.shuffle()
	for connection_socket in sockets:
		var scene: PackedScene = (
			BOSS_MODULES.pick_random()
		)
		
		var boss: Node2D = scene.instantiate()
		dungeon.add_child(boss)
		
		var direction: String = (
			get_socket_direction(
				connection_socket
			)
		)
		
		var input_name: String = ""
		match direction:
			"right":
				input_name = "SocketLeft"
			"left":
				input_name = "SocketRight"
			"down":
				input_name = "SocketUp"
			"up":
				input_name = "SocketDown"
			
		
		var boss_socket: Marker2D = get_socket(
			boss,
			input_name
		)
		
		if boss_socket == null:
			boss.queue_free()
			continue
		
		align_module(
			boss,
			boss_socket,
			connection_socket
		)
		
		if module_overlaps(boss):
			boss.queue_free()
			continue
			
		generated_modules.append(
			boss
		)
		
		register_module(
			boss
		)
		
		print("BOSS creado")
		return
		
	print(
		"No se encontró una posición válida para Boss"
	)

func clear_dungeon():
	for child in dungeon.get_children():
		child.queue_free()
		
	generated_modules.clear()
	occupied_rects.clear()
	pending_sockets.clear()
	treasure_created = false
