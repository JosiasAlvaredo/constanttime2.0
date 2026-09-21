extends Node2D

signal level_started(level_index: int)
signal game_completed

@export var levels: Array[LevelData] = []
@export var exit_trigger_size: Vector2 = Vector2(32, 128)

var current_level_index: int = 0
var is_transitioning: bool = false

# Datos del nivel actual (los rellena apply_level_data)
var modules_to_generate: int = 0
var treasure_room_count: int = 0
var start_module: PackedScene
var room_modules: Array[PackedScene] = []
var corridor_h_modules: Array[PackedScene] = []
var corridor_v_modules: Array[PackedScene] = []
var treasure_modules: Array[PackedScene] = []
var boss_modules: Array[PackedScene] = []

# Cantidad de regeneraciones de mazmorras
const MAX_GENERATION_RETRIES: int = 50
# Cantidad máxima de intentos
const MAX_ATTEMPTS: int = 1000

const ROOM_WEIGHT: int = 7
const CORRIDOR_H_WEIGHT: int = 3
const CORRIDOR_V_WEIGHT: int = 3

const HORIZONTAL_SOCKET_WEIGHT: int = 11
const VERTICAL_SOCKET_WEIGHT: int = 2


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


@onready var dungeon: Node2D = $Dungeon

var generated_modules: Array[Node2D] = []
var occupied_rects: Array[Rect2] = []
var pending_sockets: Array[Marker2D] = []

func _ready():
	randomize()
	dungeon.z_index = -10
	add_to_group("dungeon_generator")
	
	start_level(0)


# NIVELES
func start_level(index: int):
	if index < 0 or index >= levels.size():
		push_error("No existe el nivel " + str(index) + ". Asigná LevelData en 'levels'.")
		return
	
	if not validate_level_data(levels[index], index):
		return
	
	current_level_index = index
	apply_level_data(levels[index])
	generate_dungeon()
	level_started.emit(index)


# Avisa con un mensaje claro si el LevelData está incompleto
func validate_level_data(data: LevelData, index: int) -> bool:
	var label: String = "LevelData del nivel %d" % (index + 1)
	if data == null:
		push_error(label + ": el slot está vacío en el Inspector.")
		return false
	
	var ok: bool = true
	if data.start_module == null:
		push_error(label + ": falta 'start_module'.")
		ok = false
	if data.boss_modules.is_empty():
		push_error(label + ": 'boss_modules' está vacío (sin jefe no hay generación válida).")
		ok = false
	if data.treasure_room_count > 0 and data.treasure_modules.is_empty():
		push_error(label + ": 'treasure_room_count' es %d pero 'treasure_modules' está vacío." % data.treasure_room_count)
		ok = false
	if data.room_modules.is_empty():
		push_error(label + ": 'room_modules' está vacío.")
		ok = false
	return ok


func apply_level_data(data: LevelData):
	modules_to_generate = data.modules_to_generate
	treasure_room_count = data.treasure_room_count
	start_module = data.start_module
	room_modules = data.room_modules
	corridor_h_modules = data.corridor_h_modules
	corridor_v_modules = data.corridor_v_modules
	treasure_modules = data.treasure_modules
	boss_modules = data.boss_modules


# Llamado (deferred) por el trigger de salida de la sala del jefe
func load_next_level():
	if is_transitioning:
		return
	is_transitioning = true
	
	var next_index: int = current_level_index + 1
	if next_index >= levels.size():
		print("No hay más niveles: juego completado")
		game_completed.emit()
		is_transitioning = false
		return
	
	print("CARGANDO NIVEL ", next_index + 1)
	clear_dungeon()
	start_level(next_index)
	
	is_transitioning = false


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
			treasures_created >= treasure_room_count
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
					treasure_room_count
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
	var start: Node2D = start_module.instantiate()
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
		generated_modules.size() < modules_to_generate + 1
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
		treasures_created < treasure_room_count
		and not pending_sockets.is_empty()
		and attempts < MAX_ATTEMPTS
	):
	
		attempts += 1
		
		var socket: Marker2D = select_socket()
		if socket == null:
			break
		var created: bool = create_special_from_socket(
			socket,
			treasure_modules,
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
			boss_modules,
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
	for scene in room_modules:
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
	for scene in corridor_h_modules:
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
	for scene in corridor_v_modules:
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

		if type_name == "BOSS":
			module.set_meta("entrance_socket", input_socket_name)
			module.set_meta("boss_room", true)
			
			# Sockets que NO son la entrada = puertas de salida hacia el próximo nivel
			var exit_sockets: Array[String] = []
			for socket_name in ALL_SOCKET_NAMES:
				if socket_name != input_socket_name and find_marker(module, socket_name) != null:
					exit_sockets.append(socket_name)
			module.set_meta("exit_sockets", exit_sockets)

		print("[", type_name, "] ", module.name, " -> ", module.global_position)

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
			var socket: Marker2D = find_marker(module, socket_name)
			if socket == null:
				continue
			
			# Socket pendiente = no se conectó nada = puerta cerrada
			set_socket_door_closed(module, socket_name, pending_sockets.has(socket))


# PUERTA DE UN SOCKET (cerrada = visible + colisión / abierta = oculta + sin colisión)
func set_socket_door_closed(module: Node2D, socket_name: String, closed: bool):
	if not SOCKET_TO_DOOR.has(socket_name):
		return
	
	var door: Node = find_node(module, SOCKET_TO_DOOR[socket_name])
	if door == null:
		return
	
	if door is CanvasItem:
		(door as CanvasItem).visible = closed
	set_collision_state_recursive(door, closed)
	
	# Las escaleras se muestran cuando la puerta está abierta
	if SOCKET_TO_DECORATION.has(socket_name):
		var stairs: Node = find_node(module, SOCKET_TO_DECORATION[socket_name])
		if stairs != null:
			set_node_visible(stairs, not closed)


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
		dungeon.remove_child(child)
		child.queue_free()
	generated_modules.clear()
	
	occupied_rects.clear()
	
	pending_sockets.clear()

# SALA DEL JEFE
# Se llaman con call_deferred desde BossRoomTrigger (dentro de callbacks de física
# no se puede modificar colisiones ni agregar Area2D directamente).

# El jugador entró: cerrar la puerta por la que entró
func lock_boss_room(boss_room: Node2D):
	if not is_instance_valid(boss_room):
		return
	
	var entrance: String = boss_room.get_meta("entrance_socket", "")
	if entrance == "":
		push_error("La sala del jefe no tiene 'entrance_socket'.")
		return
	
	set_socket_door_closed(boss_room, entrance, true)
	print("Puerta de entrada del jefe cerrada: ", entrance)


# El jefe murió: abrir la entrada, abrir la salida y habilitar el paso al próximo nivel
func complete_boss_room(boss_room: Node2D):
	if not is_instance_valid(boss_room):
		return
	
	var entrance: String = boss_room.get_meta("entrance_socket", "")
	if entrance != "":
		set_socket_door_closed(boss_room, entrance, false)
	
	var exit_sockets: Array = boss_room.get_meta("exit_sockets", [])
	for socket_name in exit_sockets:
		set_socket_door_closed(boss_room, socket_name, false)
		create_exit_trigger(boss_room, socket_name)
	
	print("Jefe derrotado: puertas abiertas")


func create_exit_trigger(boss_room: Node2D, socket_name: String):
	var socket: Marker2D = find_marker(boss_room, socket_name)
	if socket == null:
		return
	
	# Puertas izquierda/derecha = área alta; arriba/abajo = área ancha
	var size: Vector2 = exit_trigger_size
	if socket_name == "SocketUp" or socket_name == "SocketDown":
		size = Vector2(size.y, size.x)
	
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = size
	
	var shape: CollisionShape2D = CollisionShape2D.new()
	shape.shape = rect
	
	var area: Area2D = Area2D.new()
	area.name = "NextLevelTrigger"
	area.collision_layer = 0
	area.collision_mask = 0xFFFFFFFF # se filtra por 'body is Player'
	area.add_child(shape)
	boss_room.add_child(area)
	area.global_position = socket.global_position
	area.body_entered.connect(_on_exit_trigger_body_entered)


func _on_exit_trigger_body_entered(body: Node2D):
	if not body is Player:
		return
	# Deferred: no se puede borrar/crear cuerpos físicos dentro de este callback
	call_deferred("load_next_level")


# Cambia colisiones de un nodo y sus hijos (deferred: seguro dentro de callbacks de física)
func set_collision_state_recursive(node: Node, enabled: bool):
	if node is CollisionShape2D or node is CollisionPolygon2D:
		node.set_deferred("disabled", not enabled)
	elif node is TileMapLayer:
		node.set_deferred("collision_enabled", enabled)
	
	for child in node.get_children():
		set_collision_state_recursive(child, enabled)
