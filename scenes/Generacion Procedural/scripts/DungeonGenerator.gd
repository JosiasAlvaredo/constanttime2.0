extends Node2D

# Cantidad de módulos normales que queremos generar
const MODULES_TO_GENERATE: int = 20
# Cantidad de salas de tesoro
const TREASURE_ROOM_COUNT: int = 2
# Cantidad de regeneraciones de mazmorras
const MAX_GENERATION_RETRIES: int = 50
# Cantidad máxima de intentos
const MAX_ATTEMPTS: int = 1000

const ROOM_WEIGHT: int = 7
const CORRIDOR_H_WEIGHT: int = 3
const CORRIDOR_V_WEIGHT: int = 3

const HORIZONTAL_SOCKET_WEIGHT: int = 9
const VERTICAL_SOCKET_WEIGHT: int = 1


const SOCKET_TO_DOOR: Dictionary = {
	"SocketLeft": "puertaLeft",
	"SocketRight": "puertaRigth",
	"SocketUp": "puertaUp",
	"SocketDown": "puertaDown"
}

const SOCKET_TO_DECORATION: Dictionary = {
	"SocketUp": "escaleras"
}

const ALL_SOCKET_NAMES: Array[String] = [
	"SocketLeft",
	"SocketRight",
	"SocketUp",
	"SocketDown"
]


const START_MODULE: PackedScene = preload("res://scenes/Generacion Procedural/Cueva/start/StartRoom_01.tscn")


const ROOM_MODULES: Array[PackedScene] = [
	preload("res://scenes/Generacion Procedural/Cueva/rooms/normal/room_01.tscn"),
	preload("res://scenes/Generacion Procedural/Cueva/rooms/normal/room_02.tscn"),
	preload("res://scenes/Generacion Procedural/Cueva/rooms/normal/room_03.tscn")
]

# CORREDORES HORIZONTALES
const CORRIDOR_H_MODULES: Array[PackedScene] = [
	preload("res://scenes/Generacion Procedural/Cueva/corridors/horizontal/corridorH_01.tscn")
]

# CORREDORES VERTICALES
const CORRIDOR_V_MODULES: Array[PackedScene] = [
	preload("res://scenes/Generacion Procedural/Cueva/corridors/vertical/corridorV_01.tscn")
]

# HABITACIONES DE TESOROS
const TREASURE_MODULES: Array[PackedScene] = [
	preload("res://scenes/Generacion Procedural/Cueva/treasure/treasure_01.tscn"),
	preload("res://scenes/Generacion Procedural/Cueva/treasure/treasure_02.tscn")
]

# HABITACIONES DE JEFES
const BOSS_MODULES: Array[PackedScene] = [
	preload("res://scenes/Generacion Procedural/Cueva/boss/boss_01.tscn")
]


@onready var dungeon: Node2D = $Dungeon
@onready var player: Node2D = $Player

var generated_modules: Array[Node2D] = []
var occupied_rects: Array[Rect2] = []
var pending_sockets: Array[Marker2D] = []

func _ready():
	randomize()
	dungeon.z_index = -10

	generate_dungeon()


# GENERACIÓN PRINCIPAL
func generate_dungeon():
	var generation_valid: bool = false
	var generation_attempt: int = 0
	while not generation_valid and generation_attempt < MAX_GENERATION_RETRIES:
		generation_attempt += 1
		print("INTENTO DE GENERACIÓN: ", generation_attempt)
		var result: Dictionary = generate_dungeon_attempt()
		var module_count: int = result["module_count"]
		var treasures_created: int = result["treasures"]
		var boss_created: bool = result["boss"]
		
		var enough_modules: bool = (
			module_count > 1
		)
		var enough_treasures: bool = (
			treasures_created >= TREASURE_ROOM_COUNT
		)
		var has_boss: bool = boss_created
		generation_valid = (
			enough_modules
			and enough_treasures
			and has_boss
		)
		
		# GENERACIÓN INVÁLIDA
		if not generation_valid:
			print("GENERACIÓN DESCARTADA")
			if not enough_modules:
				print("- Solo se generó un módulo.")
			if not enough_treasures:
				print(
					"- Faltan salas de tesoro: ",
					treasures_created,
					"/",
					TREASURE_ROOM_COUNT
				)
			if not has_boss:
				print("- No se generó la sala de Boss.")
			clear_dungeon()
	
	# RESULTADO FINAL
	if generation_valid:
		close_unused_sockets()
		print("MAZMORRA GENERADA CORRECTAMENTE")
	else:
		print("NO SE PUDO GENERAR UNA MAZMORRA VÁLIDA")
		push_error("Se alcanzó MAX_GENERATION_RETRIES.")


func generate_dungeon_attempt() -> Dictionary:
	clear_dungeon()
	var start: Node2D = START_MODULE.instantiate()
	dungeon.add_child(start)
	start.position = Vector2.ZERO
	generated_modules.append(start)
	register_module(start)

	# SOCKET RIGHT
	var start_socket: Marker2D = find_marker(
		start,
		"SocketRight"
	)

	if start_socket == null:
		push_error(
			"StartRoom no tiene SocketRight."
		)
		return {
			"module_count": 1,
			"treasures": 0,
			"boss": false
		}
	
	pending_sockets.append(
		start_socket
	)
	
	# GENERAR MÓDULOS
	var attempts: int = 0
	while (
		generated_modules.size() < MODULES_TO_GENERATE + 1
		and not pending_sockets.is_empty()
		and attempts < MAX_ATTEMPTS
	):
		attempts += 1
		var socket: Marker2D = select_socket()
		if socket == null:
			break
		
		var created: bool = create_from_socket(
			socket
		)
		
		if created:
			remove_pending_socket(socket)
	
	# TESOROS
	var treasures_created: int = 0
	
	while (
		treasures_created < TREASURE_ROOM_COUNT
		and not pending_sockets.is_empty()
		and attempts < MAX_ATTEMPTS
	):
	
		attempts += 1
		
		var socket: Marker2D = select_socket()
		if socket == null:
			break
		var created: bool = create_special_from_socket(
			socket,
			TREASURE_MODULES,
			"TREASURE"
		)
		
		if created:
			remove_pending_socket(socket)
			treasures_created += 1
		
	# BOSS
	var boss_created: bool = false
	while (
		not boss_created
		and not pending_sockets.is_empty()
		and attempts < MAX_ATTEMPTS
	):
		
		attempts += 1
		
		var socket: Marker2D = select_socket()
		if socket == null:
			break
			
		boss_created = create_special_from_socket(
			socket,
			BOSS_MODULES,
			"BOSS"
		)
		
		if boss_created:
			remove_pending_socket(socket)
		
	
	return {
		"module_count": generated_modules.size(),
		"treasures": treasures_created,
		"boss": boss_created
	}


# SELECCIONAR SOCKET
func select_socket() -> Marker2D:
	if pending_sockets.is_empty():
		return null
	
	var horizontal: Array[Marker2D] = []
	var vertical: Array[Marker2D] = []
	
	for socket in pending_sockets:
		match socket.name:
			"SocketLeft", "SocketRight":
				horizontal.append(socket)
			"SocketUp", "SocketDown":
				vertical.append(socket)
		
	if horizontal.is_empty() and vertical.is_empty():
		return vertical.pick_random()
		return horizontal.pick_random()
	
	
	# PESOS
	var horizontal_weight: int = (
		horizontal.size()
		* HORIZONTAL_SOCKET_WEIGHT
	)
	
	var vertical_weight: int = (
		vertical.size()
		* VERTICAL_SOCKET_WEIGHT
	)
	
	var total_weight: int = (
		horizontal_weight
		+ vertical_weight
	)
	
	var value: int = randi_range(
		1,
		total_weight
	)
	
	
	if value <= horizontal_weight:
		return horizontal.pick_random()
	return vertical.pick_random()


# CREAR MÓDULO
func create_from_socket(connection_socket: Marker2D) -> bool:
	var direction: String = get_socket_direction(connection_socket)
	if direction == "":
		return false
	
	var module_types: Array[Dictionary] = []
	
	# Room
	module_types.append({
		"type": "ROOM",
		"weight": ROOM_WEIGHT
	})
	
	# Corridor H
	module_types.append({
		"type": "CORRIDOR_H",
		"weight": CORRIDOR_H_WEIGHT
	})
	
	# Corridor V
	module_types.append({
		"type": "CORRIDOR_V",
		"weight": CORRIDOR_V_WEIGHT
	})
	
	# ORDEN ALEATORIO
	module_types.shuffle()
	
	# ELEGIR TIPO
	var selected_type: String = choose_module_type(
		module_types
	)
	
	# CREAR CANDIDATOS
	var candidates: Array[Dictionary] = []
	
	# ROOM
	if selected_type == "ROOM":
		add_compatible_room(
			candidates,
			direction
		)
	
	# CORRIDOR H
	elif selected_type == "CORRIDOR_H":
		add_compatible_corridor_h(
			candidates,
			direction
		)
	
	# CORRIDOR V
	elif selected_type == "CORRIDOR_V":
		add_compatible_corridor_v(
			candidates,
			direction
		)
	
	# SI EL TIPO ELEGIDO NO ES COMPATIBLE
	if candidates.is_empty():
		for fallback in [
			"ROOM",
			"CORRIDOR_H",
			"CORRIDOR_V"
		]:
			if fallback == selected_type:
				continue
			candidates.clear()
			
			if fallback == "ROOM":
				add_compatible_room(
					candidates,
					direction
				)
			elif fallback == "CORRIDOR_H":
				add_compatible_corridor_h(
					candidates,
					direction
				)
			elif fallback == "CORRIDOR_V":
				add_compatible_corridor_v(
					candidates,
					direction
				)
			
			if not candidates.is_empty():
				break
		
	if candidates.is_empty():
		return false
	candidates.shuffle()
	
	for candidate in candidates:
		var scene: PackedScene = (candidate["scene"])
		
		var input_socket_name: String = (candidate["socket"])
		
		var module: Node2D = (scene.instantiate())
		
		dungeon.add_child(module)
		
		var input_socket: Marker2D = find_marker(module, input_socket_name)
		
		if input_socket == null:
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
		generated_modules.append(
			module
		)
		
		register_module(module)
		
		# AGREGAR SOCKETS
		add_module_sockets(
			module,
			input_socket_name
		)
		
		print("[", selected_type, "] ", module.name, " -> ", module.global_position)
		return true
	return false
	

# ROOM COMPATIBLE
func add_compatible_room(candidates: Array[Dictionary], direction: String):
	var socket_name: String = get_opposite_socket(direction)
	
	if socket_name == "":
		return
	for scene in ROOM_MODULES:
		candidates.append({
			"scene": scene,
			"socket": socket_name
		})

# CORRIDOR H COMPATIBLE
func add_compatible_corridor_h(candidates: Array[Dictionary], direction: String):
	var socket_name: String = ""
	
	match direction:
		"right":
			socket_name = "SocketLeft"
		"left":
			socket_name = "SocketRight"
		"down":
			socket_name = "SocketUp"
		"up":
			return
	
	if socket_name == "":
		return
	for scene in CORRIDOR_H_MODULES:
		candidates.append({
			"scene": scene,
			"socket": socket_name
		})

# CORRIDOR V COMPATIBLE
func add_compatible_corridor_v(candidates: Array[Dictionary], direction: String):
	var socket_name: String = get_opposite_socket(
		direction
	)
	
	if socket_name == "":
		return
	for scene in CORRIDOR_V_MODULES:
		candidates.append({
			"scene": scene,
			"socket": socket_name
		})

# ELEGIR TIPO DE MÓDULO
func choose_module_type(types: Array[Dictionary]) -> String:
	var total: int = 0
	for entry in types:
		total += int(entry["weight"])

	var value: int = randi_range(1, total)
	for entry in types:
		value -= int(entry["weight"])
		
		if value <= 0:
			return String(entry["type"])
	return "ROOM"


# SOCKET OPUESTO
func get_opposite_socket(direction: String) -> String:
	match direction:
		"right":
			return "SocketLeft"
		"left":
			return "SocketRight"
		"up":
			return "SocketDown"
		"down":
			return "SocketUp"
	return ""


# CREAR SALA ESPECIAL
func create_special_from_socket(connection_socket: Marker2D, scenes: Array[PackedScene], type_name: String) -> bool:
	var direction: String = get_socket_direction(
		connection_socket
	)
	
	if direction == "":
		return false
		
	var input_socket_name: String = (
		get_opposite_socket(direction)
	)
	
	var shuffled_scenes: Array[PackedScene] = (
		scenes.duplicate()
	)
	shuffled_scenes.shuffle()
	
	for scene in shuffled_scenes:
		var module: Node2D = (
			scene.instantiate()
		)
		
		dungeon.add_child(module)
		
		var input_socket: Marker2D = find_marker(
			module,
			input_socket_name
		)
		
		if input_socket == null:
			module.queue_free()
			continue
			
		align_module(module, input_socket, connection_socket)
		
		if module_overlaps(module):
			module.queue_free()
			continue
		
		generated_modules.append(module)
		register_module(module)

		print("[", type_name,"] ", module.name, " -> ", module.global_position)
		
		add_terminal_sockets(
			module,
			input_socket_name
		)
		return true
	return false


# AGREGAR SOCKETS
func add_module_sockets(module: Node2D,used_socket: String):
	if is_room(module):
		add_room_sockets(module, used_socket)
		return
		
	if is_horizontal_corridor(module):
		add_horizontal_sockets(
			module,
			used_socket
		)
		
		return
	
	if is_vertical_corridor(module):
		add_vertical_sockets(
			module,
			used_socket
		)


# ROOM
func add_room_sockets(room: Node2D, used_socket: String):
	for socket_name in ALL_SOCKET_NAMES:
		if socket_name == used_socket:
			continue
		
		var socket: Marker2D = find_marker(
			room,
			socket_name
		)
		
		if socket != null:
			pending_sockets.append(socket)
	
# CORRIDOR H
func add_horizontal_sockets(corridor: Node2D, used_socket: String):
	if used_socket != "SocketLeft":
		var left: Marker2D = find_marker(
			corridor,
			"SocketLeft"
		)
		
		if left != null:
			pending_sockets.append(left)
		
	if used_socket != "SocketRight":
		var right: Marker2D = find_marker(
			corridor,
			"SocketRight"
		)
		
		if right != null:
			pending_sockets.append(right)
		
	if used_socket != "SocketDown":
		var down: Marker2D = find_marker(
			corridor,
			"SocketDown"
		)
	
		if down != null:
			pending_sockets.append(down)


# CORRIDOR V
func add_vertical_sockets(corridor: Node2D, used_socket: String):
	for socket_name in ALL_SOCKET_NAMES:
		if socket_name == used_socket:
			continue
			
		var socket: Marker2D = find_marker(
			corridor,
			socket_name
		)
		
		if socket != null:
			pending_sockets.append(socket)


# SOCKETS DE MÓDULOS TERMINALES (BOSS / TREASURE)
func add_terminal_sockets(module: Node2D, used_socket: String):
	for socket_name in ALL_SOCKET_NAMES:
		if socket_name == used_socket:
			continue
		var socket: Marker2D = find_marker(
			module,
			socket_name
		)
		
		if socket != null:
			pending_sockets.append(socket)


# ALINEAR
func align_module(module: Node2D, module_socket: Marker2D,target_socket: Marker2D):
	var offset: Vector2 = (
		target_socket.global_position
		- module_socket.global_position
	)
	
	module.global_position += offset


# DIRECCIÓN DEL SOCKET
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


# BUSCAR MARKER
func find_marker(root: Node, marker_name: String) -> Marker2D:
	if root.name == marker_name:
		if root is Marker2D:
			return root as Marker2D
		
	for child in root.get_children():
		var result: Marker2D = find_marker(
			child,
			marker_name
		)
		if result != null:
			return result
	return null



# IDENTIFICAR ROOM
func is_room(module: Node2D) -> bool:
	return module.scene_file_path.contains("/rooms/normal/")


# IDENTIFICAR CORRIDOR H
func is_horizontal_corridor(module: Node2D) -> bool:
	return module.scene_file_path.contains("/corridors/horizontal/")


# IDENTIFICAR CORRIDOR V
func is_vertical_corridor(module: Node2D) -> bool:
	return module.scene_file_path.contains("/corridors/vertical/")


# BOUNDS
func get_module_rect(module: Node2D) -> Rect2:
	if is_horizontal_corridor(module):
		var polygon_node: CollisionPolygon2D = (
			find_collision_polygon(module)
		)
		
		if polygon_node == null:
			push_error(module.name + " no tiene CollisionPolygon2D para Bounds")
			return Rect2()
		if polygon_node.polygon.is_empty():
			push_error(module.name + " tiene un CollisionPolygon2D vacío")
			return Rect2()
		
		var polygon: PackedVector2Array = (
			polygon_node.polygon
		)
		
		var first_point: Vector2 = (
			polygon_node.global_transform
			* polygon[0]
		)
		
		var rect: Rect2 = Rect2(
			first_point,
			Vector2.ZERO
		)
		
		for point in polygon:
			var global_point: Vector2 = (
				polygon_node.global_transform
				* point
			)
			
			rect = rect.expand(global_point)
		return rect
	
	var bounds: CollisionShape2D = (
		find_collision_shape(module)
	)
	
	if bounds == null:
		push_error(module.name + " no tiene Bounds")
		return Rect2()
		
	if bounds.shape == null:
		push_error(module.name + " tiene Bounds sin Shape")
		return Rect2()
	var shape: Shape2D = bounds.shape
	
	if shape is RectangleShape2D:
		var rectangle: RectangleShape2D = (
			shape as RectangleShape2D
		)
		
		var size: Vector2 = rectangle.size
		
		return Rect2(
			bounds.global_position - size / 2.0,
			size
		)
		
	push_error(module.name + " necesita RectangleShape2D.")
	return Rect2()


func find_collision_polygon(root: Node) -> CollisionPolygon2D:
	if root is CollisionPolygon2D:
		return root as CollisionPolygon2D
		
	for child in root.get_children():
		var result: CollisionPolygon2D = (
			find_collision_polygon(child)
		)
		
		if result != null:
			return result
	return null


func find_collision_shape(root: Node) -> CollisionShape2D:
	if root is CollisionShape2D:
		return root as CollisionShape2D
		
	for child in root.get_children():
		var result: CollisionShape2D = (
			find_collision_shape(child)
		)
		
		if result != null:
			return result
	return null


# SOLAPAMIENTO
func module_overlaps(module: Node2D) -> bool:
	var new_rect: Rect2 = (
		get_module_rect(module)
	)
	
	if new_rect.size == Vector2.ZERO:
		return true
	for existing_rect in occupied_rects:
		if new_rect.intersects(
			existing_rect,
			false
		):
			return true
	return false


# REGISTRAR
func register_module(module: Node2D):
	var rect: Rect2 = (
		get_module_rect(module)
	)
	
	if rect.size == Vector2.ZERO:
		return
	
	occupied_rects.append(
		rect
	)


# REMOVER SOCKET PENDIENTE
func remove_pending_socket(socket: Marker2D):
	var index: int = (
		pending_sockets.find(socket)
	)
	
	if index >= 0:
		pending_sockets.remove_at(
			index
		)


# CERRAR PUERTAS
func close_unused_sockets():
	print("Cerrando conexiones no utilizadas...")
	
	for module in generated_modules:
		for socket_name in SOCKET_TO_DOOR:
			process_door(module, socket_name, SOCKET_TO_DOOR[socket_name])


# PROCESAR PUERTA
func process_door(module: Node2D, socket_name: String, door_name: String):
	
	var socket: Marker2D = find_marker(
		module,
		socket_name
	)
	
	var door: Node = find_node(
		module,
		door_name
	)
	
	if socket == null:
		return
	
	if door != null:
		var is_closed: bool = pending_sockets.has(socket)
		
		set_node_visible(
			door,
			is_closed
		)
		
		# ESCALERA RELACIONADA CON ESTE SOCKET
		if SOCKET_TO_DECORATION.has(socket_name):
			var stairs_name: String = SOCKET_TO_DECORATION[socket_name]
			var stairs: Node = find_node(
				module,
				stairs_name
			)
			
			if stairs == null:
				set_node_visible(
					stairs,
					not is_closed
				)


# BUSCAR CUALQUIER NODO
func find_node(root: Node, node_name: String) -> Node:
	if root.name == node_name:
		return root
	
	for child in root.get_children():
		var result: Node = find_node(
			child,
			node_name
		)
		
		if result != null:
			return result
	return null


# VISIBILIDAD
func set_node_visible(node: Node, value: bool):
	if node is CanvasItem:
		var canvas_item: CanvasItem = node as CanvasItem
		canvas_item.visible = value
	
	if node is TileMapLayer:
		var tilemap: TileMapLayer = node as TileMapLayer
		tilemap.collision_enabled = value


# LIMPIAR
func clear_dungeon():
	for child in dungeon.get_children():
		child.queue_free()
	generated_modules.clear()
	
	occupied_rects.clear()
	
	pending_sockets.clear()
