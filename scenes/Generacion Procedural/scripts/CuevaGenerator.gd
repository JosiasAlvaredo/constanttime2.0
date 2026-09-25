extends Node2D


signal level_started(level_index: int)
signal game_completed


@export_range(1, 1000, 1) var modules_to_generate: int = 20
@export_range(0, 100, 1) var treasure_room_count: int = 2

var start_module

var room_modules = []

var corridor_h_modules = []

var corridor_v_modules = []

var treasure_modules = []

var boss_modules = []

@export var exit_trigger_size: Vector2 = Vector2(32, 128)


@export_category("Background")
@export var background_tileset: TileSet
@export var background_tiles: Array[Vector2i] = []
@export var background_margin_tiles: int = 2
@export var background_source_id: int = 0
@export_range(0.0, 1.0, 0.01) var background_variant_chance: float = 0.0


var current_level_index: int = 0
var is_transitioning: bool = false


# ============================================================
# CONFIGURACIÓN
# ============================================================

const MAX_GENERATION_RETRIES: int = 50
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


# ============================================================
# NODOS
# ============================================================

@onready var dungeon: Node2D = $Dungeon
@onready var background: DungeonBackground = $Background


# ============================================================
# DATOS DE GENERACIÓN
# ============================================================

var generated_modules: Array[Node2D] = []
var occupied_rects: Array[Rect2] = []
var pending_sockets: Array[Marker2D] = []


# ============================================================
# READY
# ============================================================

func _ready():
	print("\n")
	print("====================================================")
	print("             DUNGEON GENERATOR START")
	print("====================================================")
	
	
	
	randomize()

	print("[READY] Randomize ejecutado")

	dungeon.z_index = -10

	print("[READY] Dungeon Z Index: ", dungeon.z_index)

	add_to_group("dungeon_generator")

	print("[READY] Agregado al grupo dungeon_generator")

	print("[READY] Módulos a generar: ", modules_to_generate)
	print("[READY] Salas de tesoro: ", treasure_room_count)
	print("[READY] Start module: ", start_module)
	print("[READY] Rooms: ", room_modules.size())
	print("[READY] Corridors H: ", corridor_h_modules.size())
	print("[READY] Corridors V: ", corridor_v_modules.size())
	print("[READY] Treasures: ", treasure_modules.size())
	print("[READY] Bosses: ", boss_modules.size())

	start_level()


func obtener_escenas(carpeta: String) -> Array[String]:
	var escenas: Array[String] = []
	var dir := DirAccess.open(carpeta)

	if dir == null:
		return escenas

	dir.list_dir_begin()
	var archivo := dir.get_next()

	while archivo != "":
		if not dir.current_is_dir() and archivo.ends_with(".tscn"):
			escenas.append(carpeta.path_join(archivo))

		archivo = dir.get_next()

	dir.list_dir_end()

	return escenas

# ============================================================
# NIVEL ACTUAL
# ============================================================

func start_level():

	print("\n")
	print("====================================================")
	print("                 START LEVEL")
	print("                 NIVEL CONFIGURADO")
	print("====================================================")

	if not validate_level_data():
		print("[LEVEL ERROR] Configuración del generador inválida")
		return

	print("[LEVEL] Configuración válida")

	generate_dungeon()

	print("[LEVEL] Dungeon generada")

	build_background()

	print("[LEVEL] Background construido")

	level_started.emit(0)

	print("[LEVEL] level_started emitido")


# ============================================================
# VALIDAR CONFIGURACIÓN
# ============================================================

func validate_level_data() -> bool:

	print("\n[VALIDATE] ===============================")

	var ok: bool = true

	print("[VALIDATE] modules_to_generate: ", modules_to_generate)
	print("[VALIDATE] treasure_room_count: ", treasure_room_count)
	print("[VALIDATE] start_module: ", start_module)
	print("[VALIDATE] room_modules: ", room_modules.size())
	print("[VALIDATE] corridor_h_modules: ", corridor_h_modules.size())
	print("[VALIDATE] corridor_v_modules: ", corridor_v_modules.size())
	print("[VALIDATE] treasure_modules: ", treasure_modules.size())
	print("[VALIDATE] boss_modules: ", boss_modules.size())

	if modules_to_generate < 1:
		push_error("'modules_to_generate' debe ser mayor que 0.")
		print("[VALIDATE ERROR] modules_to_generate inválido")
		ok = false

	if start_module == null:
		push_error("Falta 'start_module'.")
		print("[VALIDATE ERROR] Falta start_module")
		ok = false

	if boss_modules.is_empty():
		push_error("'boss_modules' está vacío.")
		print("[VALIDATE ERROR] boss_modules vacío")
		ok = false

	if treasure_room_count > 0 and treasure_modules.is_empty():
		push_error(
			"'treasure_room_count' es %d pero 'treasure_modules' está vacío."
			% treasure_room_count
		)
		print("[VALIDATE ERROR] No hay escenas de tesoro")
		ok = false

	if room_modules.is_empty():
		push_error("'room_modules' está vacío.")
		print("[VALIDATE ERROR] room_modules vacío")
		ok = false

	print("[VALIDATE] Resultado: ", ok)

	return ok


# ============================================================
# CARGAR SIGUIENTE NIVEL
# ============================================================

func load_next_level():

	print("\n[LEVEL TRANSITION] ===============================")

	if is_transitioning:
		print("[LEVEL TRANSITION] Ya está cambiando de nivel")
		return

	is_transitioning = true

	print("[LEVEL TRANSITION] Este generador representa un nivel único")
	print("[LEVEL TRANSITION] Emitiendo game_completed")

	game_completed.emit()

	is_transitioning = false


# ============================================================
# GENERACIÓN PRINCIPAL
# ============================================================

func generate_dungeon():

	print("\n")
	print("====================================================")
	print("              GENERATE DUNGEON")
	print("====================================================")

	var generation_valid: bool = false
	var generation_attempt: int = 0

	while not generation_valid and generation_attempt < MAX_GENERATION_RETRIES:

		generation_attempt += 1

		print("\n")
		print("----------------------------------------------------")
		print("INTENTO DE GENERACIÓN: ", generation_attempt)
		print("----------------------------------------------------")

		var result: Dictionary = generate_dungeon_attempt()

		print("[GENERATION] Resultado recibido")

		var module_count: int = result["module_count"]
		var treasures_created: int = result["treasures"]
		var boss_created: bool = result["boss"]

		print("[GENERATION] Módulos: ", module_count)
		print("[GENERATION] Tesoros: ", treasures_created)
		print("[GENERATION] Boss: ", boss_created)

		var enough_modules: bool = module_count > 1

		var enough_treasures: bool = (
			treasures_created >= treasure_room_count
		)

		var has_boss: bool = boss_created

		generation_valid = (
			enough_modules
			and enough_treasures
			and has_boss
		)

		print("[GENERATION] enough_modules: ", enough_modules)
		print("[GENERATION] enough_treasures: ", enough_treasures)
		print("[GENERATION] has_boss: ", has_boss)
		print("[GENERATION] generation_valid: ", generation_valid)

		if not generation_valid:

			print("\n[GENERATION] GENERACIÓN DESCARTADA")

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

			print("[GENERATION] Limpiando intento...")

			clear_dungeon()

	if generation_valid:

		print("\n[GENERATION] Generación válida")

		close_unused_sockets()

		print("[GENERATION] Sockets cerrados")

		print("MAZMORRA GENERADA CORRECTAMENTE")

	else:

		print("\n[GENERATION ERROR]")
		print("NO SE PUDO GENERAR UNA MAZMORRA VÁLIDA")

		push_error(
			"Se alcanzó MAX_GENERATION_RETRIES."
		)


# ============================================================
# INTENTO DE GENERACIÓN
# ============================================================

func generate_dungeon_attempt() -> Dictionary:

	print("\n")
	print("====================================================")
	print("             GENERATION ATTEMPT")
	print("====================================================")

	clear_dungeon()

	print("[ATTEMPT 1] Dungeon limpiada")

	if start_module == null:

		print("[ATTEMPT ERROR] start_module es NULL")

		return {
			"module_count": 0,
			"treasures": 0,
			"boss": false
		}

	var start: Node2D = start_module.instantiate()

	if start == null:

		print("[ATTEMPT ERROR] No se pudo instanciar StartModule")

		return {
			"module_count": 0,
			"treasures": 0,
			"boss": false
		}

	print("[ATTEMPT 2] StartModule instanciado: ", start.name)

	dungeon.add_child(start)

	print("[ATTEMPT 3] StartModule agregado al Dungeon")

	start.position = Vector2.ZERO

	print("[ATTEMPT 4] StartModule posición: ", start.position)

	generated_modules.append(start)

	print(
		"[ATTEMPT 5] StartModule agregado a generated_modules"
	)

	register_module(start)

	print("[ATTEMPT 6] StartModule registrado")

	print(
		"[ATTEMPT] Rectángulos ocupados: ",
		occupied_rects.size()
	)

	# --------------------------------------------------------
	# SOCKET RIGHT
	# --------------------------------------------------------

	print("\n[START SOCKET] Buscando SocketRight...")

	var start_socket: Marker2D = find_marker(
		start,
		"SocketRight"
	)

	if start_socket == null:

		push_error(
			"StartRoom no tiene SocketRight."
		)

		print(
			"[START SOCKET ERROR] SocketRight NO encontrado"
		)

		return {
			"module_count": 1,
			"treasures": 0,
			"boss": false
		}

	print(
		"[START SOCKET] Encontrado en: ",
		start_socket.global_position
	)

	pending_sockets.append(start_socket)

	print(
		"[START SOCKET] Socket agregado a pending_sockets"
	)

	print(
		"[START SOCKET] Pendientes: ",
		pending_sockets.size()
	)

	# --------------------------------------------------------
	# GENERAR MÓDULOS
	# --------------------------------------------------------

	print("\n")
	print("====================================================")
	print("             GENERANDO MÓDULOS")
	print("====================================================")

	var attempts: int = 0

	while (
		generated_modules.size() < modules_to_generate + 1
		and not pending_sockets.is_empty()
		and attempts < MAX_ATTEMPTS
	):

		attempts += 1

		print("\n")
		print("[MODULE LOOP] Intento: ", attempts)
		print(
			"[MODULE LOOP] Módulos: ",
			generated_modules.size(),
			"/",
			modules_to_generate + 1
		)

		print(
			"[MODULE LOOP] Sockets pendientes: ",
			pending_sockets.size()
		)

		var socket: Marker2D = select_socket()

		if socket == null:

			print(
				"[MODULE LOOP ERROR] select_socket() devolvió NULL"
			)

			break

		print(
			"[MODULE LOOP] Socket elegido: ",
			socket.name
		)

		var created: bool = create_from_socket(
			socket
		)

		print(
			"[MODULE LOOP] create_from_socket(): ",
			created
		)

		if created:

			remove_pending_socket(socket)

			print(
				"[MODULE LOOP] Socket eliminado"
			)

		else:

			print(
				"[MODULE LOOP WARNING] No se pudo crear módulo"
			)

	# --------------------------------------------------------
	# TESOROS
	# --------------------------------------------------------

	print("\n")
	print("====================================================")
	print("             GENERANDO TESOROS")
	print("====================================================")

	var treasures_created: int = 0

	while (
		treasures_created < treasure_room_count
		and not pending_sockets.is_empty()
		and attempts < MAX_ATTEMPTS
	):

		attempts += 1

		print("\n[TREASURE LOOP]")
		print(
			"[TREASURE] Creando tesoro ",
			treasures_created + 1,
			"/",
			treasure_room_count
		)

		print(
			"[TREASURE] Sockets disponibles: ",
			pending_sockets.size()
		)

		var socket: Marker2D = select_socket()

		if socket == null:

			print(
				"[TREASURE ERROR] No se pudo seleccionar socket"
			)

			break

		print(
			"[TREASURE] Socket elegido: ",
			socket.name
		)

		var created: bool = create_special_from_socket(
			socket,
			treasure_modules,
			"TREASURE"
		)

		print(
			"[TREASURE] Resultado: ",
			created
		)

		if created:

			remove_pending_socket(socket)

			treasures_created += 1

			print(
				"[TREASURE] Tesoro creado. Total: ",
				treasures_created
			)

		else:

			print(
				"[TREASURE WARNING] No se pudo crear tesoro"
			)

	# --------------------------------------------------------
	# BOSS
	# --------------------------------------------------------

	print("\n")
	print("====================================================")
	print("             GENERANDO BOSS")
	print("====================================================")

	var boss_created: bool = false

	while (
		not boss_created
		and not pending_sockets.is_empty()
		and attempts < MAX_ATTEMPTS
	):

		attempts += 1

		print("\n[BOSS LOOP] Intento Boss")

		print(
			"[BOSS] Sockets disponibles: ",
			pending_sockets.size()
		)

		var socket: Marker2D = select_socket()

		if socket == null:

			print(
				"[BOSS ERROR] No se pudo seleccionar socket"
			)

			break

		print(
			"[BOSS] Socket elegido: ",
			socket.name
		)

		boss_created = create_special_from_socket(
			socket,
			boss_modules,
			"BOSS"
		)

		print(
			"[BOSS] Resultado: ",
			boss_created
		)

		if boss_created:

			remove_pending_socket(socket)

			print(
				"[BOSS] Boss creado correctamente"
			)

	# --------------------------------------------------------
	# RESULTADO
	# --------------------------------------------------------

	print("\n")
	print("====================================================")
	print("          FIN GENERATION ATTEMPT")
	print("====================================================")

	print(
		"[RESULT] Módulos: ",
		generated_modules.size()
	)

	print(
		"[RESULT] Tesoros: ",
		treasures_created
	)

	print(
		"[RESULT] Boss: ",
		boss_created
	)

	print(
		"[RESULT] Sockets pendientes: ",
		pending_sockets.size()
	)

	print(
		"[RESULT] Intentos utilizados: ",
		attempts
	)

	return {
		"module_count": generated_modules.size(),
		"treasures": treasures_created,
		"boss": boss_created
	}


# ============================================================
# SELECCIONAR SOCKET
# ============================================================

func select_socket() -> Marker2D:

	print("\n[SELECT SOCKET] ===============================")

	if pending_sockets.is_empty():

		print(
			"[SELECT SOCKET ERROR] pending_sockets está vacío"
		)

		return null

	var horizontal: Array[Marker2D] = []
	var vertical: Array[Marker2D] = []

	for socket in pending_sockets:

		if socket == null:
			print("[SELECT SOCKET WARNING] Socket NULL")
			continue

		match socket.name:

			"SocketLeft", "SocketRight":
				horizontal.append(socket)

			"SocketUp", "SocketDown":
				vertical.append(socket)

			_:
				print(
					"[SELECT SOCKET WARNING] Socket desconocido: ",
					socket.name
				)

	print(
		"[SELECT SOCKET] Horizontales: ",
		horizontal.size()
	)

	print(
		"[SELECT SOCKET] Verticales: ",
		vertical.size()
	)

	if horizontal.is_empty() and vertical.is_empty():

		print(
			"[SELECT SOCKET ERROR] No hay sockets válidos"
		)

		return null

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

	print(
		"[SELECT SOCKET] Peso H: ",
		horizontal_weight
	)

	print(
		"[SELECT SOCKET] Peso V: ",
		vertical_weight
	)

	print(
		"[SELECT SOCKET] Peso total: ",
		total_weight
	)

	if total_weight <= 0:

		print(
			"[SELECT SOCKET ERROR] Peso total inválido"
		)

		return null

	var value: int = randi_range(
		1,
		total_weight
	)

	print(
		"[SELECT SOCKET] Número aleatorio: ",
		value
	)

	if value <= horizontal_weight:

		if horizontal.is_empty():

			print(
				"[SELECT SOCKET ERROR] Intentó elegir H pero está vacío"
			)

			return null

		var selected_h: Marker2D = horizontal.pick_random()

		print(
			"[SELECT SOCKET] Elegido H: ",
			selected_h.name
		)

		return selected_h

	if vertical.is_empty():

		print(
			"[SELECT SOCKET ERROR] Intentó elegir V pero está vacío"
		)

		return null

	var selected_v: Marker2D = vertical.pick_random()

	print(
		"[SELECT SOCKET] Elegido V: ",
		selected_v.name
	)

	return selected_v


# ============================================================
# CREAR MÓDULO
# ============================================================

func create_from_socket(connection_socket: Marker2D) -> bool:

	print("\n")
	print("[CREATE] =======================================")
	print("[CREATE] Creando módulo")
	print("[CREATE] Socket: ", connection_socket.name)
	print(
		"[CREATE] Posición: ",
		connection_socket.global_position
	)

	var direction: String = get_socket_direction(
		connection_socket
	)

	print(
		"[CREATE] Dirección: ",
		direction
	)

	if direction == "":

		print(
			"[CREATE ERROR] Dirección inválida"
		)

		return false

	var module_types: Array[Dictionary] = []

	module_types.append({
		"type": "ROOM",
		"weight": ROOM_WEIGHT
	})

	module_types.append({
		"type": "CORRIDOR_H",
		"weight": CORRIDOR_H_WEIGHT
	})

	module_types.append({
		"type": "CORRIDOR_V",
		"weight": CORRIDOR_V_WEIGHT
	})

	module_types.shuffle()

	var selected_type: String = choose_module_type(
		module_types
	)

	print(
		"[CREATE] Tipo seleccionado: ",
		selected_type
	)

	var candidates: Array[Dictionary] = []

	# --------------------------------------------------------
	# CANDIDATOS
	# --------------------------------------------------------

	if selected_type == "ROOM":

		print("[CREATE] Buscando Rooms compatibles")

		add_compatible_room(
			candidates,
			direction
		)

	elif selected_type == "CORRIDOR_H":

		print("[CREATE] Buscando Corridors H compatibles")

		add_compatible_corridor_h(
			candidates,
			direction
		)

	elif selected_type == "CORRIDOR_V":

		print("[CREATE] Buscando Corridors V compatibles")

		add_compatible_corridor_v(
			candidates,
			direction
		)

	print(
		"[CREATE] Candidatos encontrados: ",
		candidates.size()
	)

	# --------------------------------------------------------
	# FALLBACK
	# --------------------------------------------------------

	if candidates.is_empty():

		print(
			"[CREATE WARNING] No hay candidatos para ",
			selected_type
		)

		for fallback in [
			"ROOM",
			"CORRIDOR_H",
			"CORRIDOR_V"
		]:

			if fallback == selected_type:
				continue

			candidates.clear()

			print(
				"[FALLBACK] Probando ",
				fallback
			)

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

			print(
				"[FALLBACK] Candidatos: ",
				candidates.size()
			)

			if not candidates.is_empty():

				print(
					"[FALLBACK] Encontrado: ",
					fallback
				)

				break

	if candidates.is_empty():

		print(
			"[CREATE ERROR] NO HAY CANDIDATOS COMPATIBLES"
		)

		return false

	candidates.shuffle()

	# --------------------------------------------------------
	# PROBAR CANDIDATOS
	# --------------------------------------------------------

	for candidate in candidates:

		print("\n[CREATE CANDIDATE] ------------------------")

		var scene: PackedScene = candidate["scene"]

		var input_socket_name: String = candidate["socket"]

		print(
			"[CANDIDATE] Socket requerido: ",
			input_socket_name
		)

		if scene == null:

			print(
				"[CANDIDATE ERROR] PackedScene NULL"
			)

			continue

		print(
			"[CANDIDATE] PackedScene válida"
		)

		var module: Node2D = scene.instantiate()

		if module == null:

			print(
				"[CANDIDATE ERROR] Instantiate() devolvió NULL"
			)

			continue

		print(
			"[CANDIDATE] Instanciado: ",
			module.name
		)

		dungeon.add_child(module)

		print(
			"[CANDIDATE] Agregado al Dungeon"
		)

		var input_socket: Marker2D = find_marker(
			module,
			input_socket_name
		)

		if input_socket == null:

			print(
				"[CANDIDATE ERROR] ",
				module.name,
				" NO tiene ",
				input_socket_name
			)

			module.queue_free()

			continue

		print(
			"[CANDIDATE] Socket encontrado: ",
			input_socket.name
		)

		print(
			"[CANDIDATE] Posición antes de alinear: ",
			module.global_position
		)

		align_module(
			module,
			input_socket,
			connection_socket
		)

		print(
			"[CANDIDATE] Posición después de alinear: ",
			module.global_position
		)

		# ----------------------------------------------------
		# SOLAPAMIENTO
		# ----------------------------------------------------

		print(
			"[CANDIDATE] Comprobando solapamiento..."
		)

		if module_overlaps(module):

			print(
				"[CANDIDATE] SOLAPAMIENTO DETECTADO"
			)

			module.queue_free()

			continue

		print(
			"[CANDIDATE] No hay solapamiento"
		)

		# ----------------------------------------------------
		# REGISTRAR
		# ----------------------------------------------------

		generated_modules.append(module)

		print(
			"[CANDIDATE] Agregado a generated_modules"
		)

		register_module(module)

		print(
			"[CANDIDATE] Registrado en occupied_rects"
		)

		add_module_sockets(
			module,
			input_socket_name
		)

		print(
			"[CANDIDATE] Nuevos sockets agregados: ",
			pending_sockets.size()
		)

		print(
			"[CREATE SUCCESS] ",
			selected_type,
			" -> ",
			module.name
		)

		print(
			"[CREATE SUCCESS] Posición: ",
			module.global_position
		)

		return true

	print(
		"[CREATE ERROR] TODOS LOS CANDIDATOS FALLARON"
	)

	return false


# ============================================================
# ROOM COMPATIBLE
# ============================================================

func add_compatible_room(
	candidates: Array[Dictionary],
	direction: String
):

	print(
		"[ROOM COMPATIBLE] Dirección: ",
		direction
	)

	var socket_name: String = get_opposite_socket(
		direction
	)

	print(
		"[ROOM COMPATIBLE] Socket requerido: ",
		socket_name
	)

	if socket_name == "":

		print(
			"[ROOM ERROR] No se pudo determinar socket"
		)

		return

	print(
		"[ROOM COMPATIBLE] Escenas disponibles: ",
		room_modules.size()
	)

	for scene in room_modules:

		if scene == null:

			print(
				"[ROOM WARNING] Escena NULL"
			)

			continue

		candidates.append({
			"scene": scene,
			"socket": socket_name
		})


# ============================================================
# CORRIDOR H COMPATIBLE
# ============================================================

func add_compatible_corridor_h(
	candidates: Array[Dictionary],
	direction: String
):

	print(
		"[CORRIDOR H] Dirección: ",
		direction
	)

	var socket_name: String = ""

	match direction:

		"right":
			socket_name = "SocketLeft"

		"left":
			socket_name = "SocketRight"

		"down":
			socket_name = "SocketUp"

		"up":
			print(
				"[CORRIDOR H] No puede conectarse desde arriba"
			)

			return

	if socket_name == "":

		print(
			"[CORRIDOR H ERROR] Socket vacío"
		)

		return

	print(
		"[CORRIDOR H] Socket requerido: ",
		socket_name
	)

	print(
		"[CORRIDOR H] Escenas disponibles: ",
		corridor_h_modules.size()
	)

	for scene in corridor_h_modules:

		if scene == null:
			continue

		candidates.append({
			"scene": scene,
			"socket": socket_name
		})


# ============================================================
# CORRIDOR V COMPATIBLE
# ============================================================

func add_compatible_corridor_v(
	candidates: Array[Dictionary],
	direction: String
):

	print(
		"[CORRIDOR V] Dirección: ",
		direction
	)

	var socket_name: String = get_opposite_socket(
		direction
	)

	print(
		"[CORRIDOR V] Socket requerido: ",
		socket_name
	)

	if socket_name == "":
		return

	for scene in corridor_v_modules:

		if scene == null:
			continue

		candidates.append({
			"scene": scene,
			"socket": socket_name
		})


# ============================================================
# ELEGIR TIPO
# ============================================================

func choose_module_type(
	types: Array[Dictionary]
) -> String:

	var total: int = 0

	for entry in types:
		total += int(entry["weight"])

	print(
		"[CHOOSE TYPE] Peso total: ",
		total
	)

	if total <= 0:

		print(
			"[CHOOSE TYPE ERROR] Peso total inválido"
		)

		return "ROOM"

	var value: int = randi_range(
		1,
		total
	)

	print(
		"[CHOOSE TYPE] Valor aleatorio: ",
		value
	)

	for entry in types:

		value -= int(entry["weight"])

		if value <= 0:

			print(
				"[CHOOSE TYPE] Elegido: ",
				entry["type"]
			)

			return String(entry["type"])

	return "ROOM"


# ============================================================
# SOCKET OPUESTO
# ============================================================

func get_opposite_socket(
	direction: String
) -> String:

	match direction:

		"right":
			return "SocketLeft"

		"left":
			return "SocketRight"

		"up":
			return "SocketDown"

		"down":
			return "SocketUp"

	print(
		"[OPPOSITE SOCKET ERROR] Dirección desconocida: ",
		direction
	)

	return ""


# ============================================================
# CREAR SALA ESPECIAL
# ============================================================

func create_special_from_socket(
	connection_socket: Marker2D,
	scenes: Array[PackedScene],
	type_name: String
) -> bool:

	print("\n")
	print("[SPECIAL] ======================================")
	print("[SPECIAL] Tipo: ", type_name)
	print("[SPECIAL] Socket: ", connection_socket.name)

	var direction: String = get_socket_direction(
		connection_socket
	)

	print(
		"[SPECIAL] Dirección: ",
		direction
	)

	if direction == "":

		print(
			"[SPECIAL ERROR] Dirección inválida"
		)

		return false

	var input_socket_name: String = get_opposite_socket(
		direction
	)

	print(
		"[SPECIAL] Socket requerido: ",
		input_socket_name
	)

	var shuffled_scenes: Array[PackedScene] = (
		scenes.duplicate()
	)

	shuffled_scenes.shuffle()

	print(
		"[SPECIAL] Escenas disponibles: ",
		shuffled_scenes.size()
	)

	for scene in shuffled_scenes:

		if scene == null:

			print(
				"[SPECIAL ERROR] PackedScene NULL"
			)

			continue

		var module: Node2D = scene.instantiate()

		if module == null:

			print(
				"[SPECIAL ERROR] No se pudo instanciar"
			)

			continue

		print(
			"[SPECIAL] Instanciado: ",
			module.name
		)

		dungeon.add_child(module)

		print(
			"[SPECIAL] Agregado al Dungeon"
		)

		var input_socket: Marker2D = find_marker(
			module,
			input_socket_name
		)

		if input_socket == null:

			print(
				"[SPECIAL ERROR] ",
				module.name,
				" no tiene ",
				input_socket_name
			)

			module.queue_free()

			continue

		print(
			"[SPECIAL] Socket encontrado"
		)

		align_module(
			module,
			input_socket,
			connection_socket
		)

		print(
			"[SPECIAL] Módulo alineado"
		)

		if module_overlaps(module):

			print(
				"[SPECIAL] SOLAPAMIENTO"
			)

			module.queue_free()

			continue

		generated_modules.append(module)

		register_module(module)

		print(
			"[SPECIAL] Módulo registrado"
		)

		if type_name == "BOSS":

			print(
				"[BOSS] Configurando metadata"
			)

			module.set_meta(
				"entrance_socket",
				input_socket_name
			)

			module.set_meta(
				"boss_room",
				true
			)

			var exit_sockets: Array[String] = []

			for socket_name in ALL_SOCKET_NAMES:

				if socket_name != input_socket_name:

					if find_marker(
						module,
						socket_name
					) != null:

						exit_sockets.append(
							socket_name
						)

			module.set_meta(
				"exit_sockets",
				exit_sockets
			)

			print(
				"[BOSS] Entrada: ",
				input_socket_name
			)

			print(
				"[BOSS] Salidas: ",
				exit_sockets
			)

		print(
			"[SPECIAL SUCCESS] ",
			type_name,
			" -> ",
			module.name
		)

		add_terminal_sockets(
			module,
			input_socket_name
		)

		return true

	print(
		"[SPECIAL ERROR] Todos los candidatos fallaron"
	)

	return false


# ============================================================
# AGREGAR SOCKETS
# ============================================================

func add_module_sockets(
	module: Node2D,
	used_socket: String
):

	print(
		"[ADD SOCKETS] Módulo: ",
		module.name
	)

	print(
		"[ADD SOCKETS] Socket utilizado: ",
		used_socket
	)

	if is_room(module):

		print("[ADD SOCKETS] Es ROOM")

		add_room_sockets(
			module,
			used_socket
		)

		return

	if is_horizontal_corridor(module):

		print("[ADD SOCKETS] Es CORRIDOR H")

		add_horizontal_sockets(
			module,
			used_socket
		)

		return

	if is_vertical_corridor(module):

		print("[ADD SOCKETS] Es CORRIDOR V")

		add_vertical_sockets(
			module,
			used_socket
		)

		return

	print(
		"[ADD SOCKETS WARNING] Tipo de módulo desconocido: ",
		module.scene_file_path
	)


# ============================================================
# ROOM SOCKETS
# ============================================================

func add_room_sockets(
	room: Node2D,
	used_socket: String
):

	print(
		"[ROOM SOCKETS] Procesando ",
		room.name
	)

	for socket_name in ALL_SOCKET_NAMES:

		if socket_name == used_socket:
			continue

		var socket: Marker2D = find_marker(
			room,
			socket_name
		)

		if socket != null:

			pending_sockets.append(
				socket
			)

			print(
				"[ROOM SOCKETS] Agregado: ",
				socket_name
			)

	print(
		"[ROOM SOCKETS] Total pendientes: ",
		pending_sockets.size()
	)


# ============================================================
# CORRIDOR H SOCKETS
# ============================================================

func add_horizontal_sockets(
	corridor: Node2D,
	used_socket: String
):

	print(
		"[H SOCKETS] Procesando ",
		corridor.name
	)

	if used_socket != "SocketLeft":

		var left: Marker2D = find_marker(
			corridor,
			"SocketLeft"
		)

		if left != null:

			pending_sockets.append(left)

			print(
				"[H SOCKETS] Left agregado"
			)

	if used_socket != "SocketRight":

		var right: Marker2D = find_marker(
			corridor,
			"SocketRight"
		)

		if right != null:

			pending_sockets.append(right)

			print(
				"[H SOCKETS] Right agregado"
			)

	if used_socket != "SocketDown":

		var down: Marker2D = find_marker(
			corridor,
			"SocketDown"
		)

		if down != null:

			pending_sockets.append(down)

			print(
				"[H SOCKETS] Down agregado"
			)

	print(
		"[H SOCKETS] Total pendientes: ",
		pending_sockets.size()
	)


# ============================================================
# CORRIDOR V SOCKETS
# ============================================================

func add_vertical_sockets(
	corridor: Node2D,
	used_socket: String
):

	print(
		"[V SOCKETS] Procesando ",
		corridor.name
	)

	for socket_name in ALL_SOCKET_NAMES:

		if socket_name == used_socket:
			continue

		var socket: Marker2D = find_marker(
			corridor,
			socket_name
		)

		if socket != null:

			pending_sockets.append(
				socket
			)

			print(
				"[V SOCKETS] Agregado: ",
				socket_name
			)

	print(
		"[V SOCKETS] Total pendientes: ",
		pending_sockets.size()
	)


# ============================================================
# SOCKETS TERMINALES
# ============================================================

func add_terminal_sockets(
	module: Node2D,
	used_socket: String
):

	print(
		"[TERMINAL SOCKETS] Procesando ",
		module.name
	)

	for socket_name in ALL_SOCKET_NAMES:

		if socket_name == used_socket:
			continue

		var socket: Marker2D = find_marker(
			module,
			socket_name
		)

		if socket != null:

			pending_sockets.append(
				socket
			)

			print(
				"[TERMINAL SOCKETS] Agregado: ",
				socket_name
			)


# ============================================================
# ALINEAR
# ============================================================

func align_module(
	module: Node2D,
	module_socket: Marker2D,
	target_socket: Marker2D
):

	print(
		"[ALIGN] Módulo: ",
		module.name
	)

	print(
		"[ALIGN] Module socket: ",
		module_socket.global_position
	)

	print(
		"[ALIGN] Target socket: ",
		target_socket.global_position
	)

	var offset: Vector2 = (
		target_socket.global_position
		- module_socket.global_position
	)

	print(
		"[ALIGN] Offset: ",
		offset
	)

	module.global_position += offset

	print(
		"[ALIGN] Nueva posición: ",
		module.global_position
	)


# ============================================================
# DIRECCIÓN
# ============================================================

func get_socket_direction(
	socket: Marker2D
) -> String:

	if socket == null:

		print(
			"[DIRECTION ERROR] Socket NULL"
		)

		return ""

	match socket.name:

		"SocketRight":
			return "right"

		"SocketLeft":
			return "left"

		"SocketUp":
			return "up"

		"SocketDown":
			return "down"

	print(
		"[DIRECTION ERROR] Socket desconocido: ",
		socket.name
	)

	return ""


# ============================================================
# BUSCAR MARKER
# ============================================================

func find_marker(
	root: Node,
	marker_name: String
) -> Marker2D:

	if root == null:

		print(
			"[FIND MARKER ERROR] Root NULL buscando ",
			marker_name
		)

		return null

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


# ============================================================
# IDENTIFICAR ROOM
# ============================================================

func is_room(
	module: Node2D
) -> bool:

	return module.scene_file_path.contains(
		"/rooms/normal/"
	)


# ============================================================
# IDENTIFICAR CORRIDOR H
# ============================================================

func is_horizontal_corridor(
	module: Node2D
) -> bool:

	return module.scene_file_path.contains(
		"/corridors/horizontal/"
	)


# ============================================================
# IDENTIFICAR CORRIDOR V
# ============================================================

func is_vertical_corridor(
	module: Node2D
) -> bool:

	return module.scene_file_path.contains(
		"/corridors/vertical/"
	)


# ============================================================
# BOUNDS
# ============================================================

func get_module_rect(
	module: Node2D
) -> Rect2:

	print(
		"[BOUNDS] Calculando bounds: ",
		module.name
	)

	if is_horizontal_corridor(module):

		var polygon_node: CollisionPolygon2D = (
			find_collision_polygon(module)
		)

		if polygon_node == null:

			push_error(
				module.name
				+ " no tiene CollisionPolygon2D para Bounds"
			)

			print(
				"[BOUNDS ERROR] CollisionPolygon2D NULL"
			)

			return Rect2()

		if polygon_node.polygon.is_empty():

			push_error(
				module.name
				+ " tiene un CollisionPolygon2D vacío"
			)

			print(
				"[BOUNDS ERROR] Polygon vacío"
			)

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

			rect = rect.expand(
				global_point
			)

		print(
			"[BOUNDS] Rect H: ",
			rect
		)

		return rect

	var bounds: CollisionShape2D = (
		find_collision_shape(module)
	)

	if bounds == null:

		push_error(
			module.name
			+ " no tiene Bounds"
		)

		print(
			"[BOUNDS ERROR] CollisionShape2D NULL"
		)

		return Rect2()

	if bounds.shape == null:

		push_error(
			module.name
			+ " tiene Bounds sin Shape"
		)

		print(
			"[BOUNDS ERROR] Shape NULL"
		)

		return Rect2()

	var shape: Shape2D = bounds.shape

	if shape is RectangleShape2D:

		var rectangle: RectangleShape2D = (
			shape as RectangleShape2D
		)

		var size: Vector2 = rectangle.size

		var rect: Rect2 = Rect2(
			bounds.global_position - size / 2.0,
			size
		)

		print(
			"[BOUNDS] Rect: ",
			rect
		)

		return rect

	push_error(
		module.name
		+ " necesita RectangleShape2D."
	)

	print(
		"[BOUNDS ERROR] Shape no es RectangleShape2D"
	)

	return Rect2()


# ============================================================
# BUSCAR COLLISION POLYGON
# ============================================================

func find_collision_polygon(
	root: Node
) -> CollisionPolygon2D:

	if root is CollisionPolygon2D:

		return root as CollisionPolygon2D

	for child in root.get_children():

		var result: CollisionPolygon2D = (
			find_collision_polygon(child)
		)

		if result != null:

			return result

	return null


# ============================================================
# BUSCAR COLLISION SHAPE
# ============================================================

func find_collision_shape(
	root: Node
) -> CollisionShape2D:

	if root is CollisionShape2D:

		return root as CollisionShape2D

	for child in root.get_children():

		var result: CollisionShape2D = (
			find_collision_shape(child)
		)

		if result != null:

			return result

	return null


# ============================================================
# SOLAPAMIENTO
# ============================================================

func module_overlaps(
	module: Node2D
) -> bool:

	print(
		"[OVERLAP] Revisando: ",
		module.name
	)

	var new_rect: Rect2 = (
		get_module_rect(module)
	)

	print(
		"[OVERLAP] Nuevo rect: ",
		new_rect
	)

	if new_rect.size == Vector2.ZERO:

		print(
			"[OVERLAP ERROR] Rect inválido"
		)

		return true

	for existing_rect in occupied_rects:

		if new_rect.intersects(
			existing_rect,
			false
		):

			print(
				"[OVERLAP] SOLAPAMIENTO"
			)

			print(
				"[OVERLAP] Nuevo: ",
				new_rect
			)

			print(
				"[OVERLAP] Existente: ",
				existing_rect
			)

			return true

	print(
		"[OVERLAP] Sin solapamiento"
	)

	return false


# ============================================================
# REGISTRAR
# ============================================================

func register_module(
	module: Node2D
):

	print(
		"[REGISTER] Registrando ",
		module.name
	)

	var rect: Rect2 = (
		get_module_rect(module)
	)

	if rect.size == Vector2.ZERO:

		print(
			"[REGISTER WARNING] Rect inválido"
		)

		return

	occupied_rects.append(
		rect
	)

	print(
		"[REGISTER] Rect agregado"
	)

	print(
		"[REGISTER] Total rectángulos: ",
		occupied_rects.size()
	)


# ============================================================
# REMOVER SOCKET
# ============================================================

func remove_pending_socket(
	socket: Marker2D
):

	if socket == null:

		print(
			"[REMOVE SOCKET ERROR] Socket NULL"
		)

		return

	var index: int = (
		pending_sockets.find(socket)
	)

	if index >= 0:

		pending_sockets.remove_at(
			index
		)

		print(
			"[REMOVE SOCKET] Eliminado: ",
			socket.name
		)

	else:

		print(
			"[REMOVE SOCKET WARNING] Socket no encontrado"
		)


# ============================================================
# CERRAR PUERTAS
# ============================================================

func close_unused_sockets():

	print("\n[CLOSE DOORS] =================================")

	print(
		"[CLOSE DOORS] Módulos: ",
		generated_modules.size()
	)

	for module in generated_modules:

		print(
			"[CLOSE DOORS] Revisando: ",
			module.name
		)

		for socket_name in SOCKET_TO_DOOR:

			var socket: Marker2D = find_marker(
				module,
				socket_name
			)

			if socket == null:

				continue

			var closed: bool = (
				pending_sockets.has(socket)
			)

			print(
				"[CLOSE DOORS] ",
				module.name,
				" | ",
				socket_name,
				" | Cerrada: ",
				closed
			)

			set_socket_door_closed(
				module,
				socket_name,
				closed
			)


# ============================================================
# PUERTA
# ============================================================

func set_socket_door_closed(
	module: Node2D,
	socket_name: String,
	closed: bool
):

	print(
		"[DOOR] ",
		module.name,
		" | ",
		socket_name,
		" | closed = ",
		closed
	)

	if not SOCKET_TO_DOOR.has(
		socket_name
	):

		print(
			"[DOOR ERROR] Socket no está en SOCKET_TO_DOOR"
		)

		return

	var door: Node = find_node(
		module,
		SOCKET_TO_DOOR[socket_name]
	)

	if door == null:

		print(
			"[DOOR WARNING] No se encontró puerta: ",
			SOCKET_TO_DOOR[socket_name]
		)

		return

	if door is CanvasItem:

		(door as CanvasItem).visible = closed

	set_collision_state_recursive(
		door,
		closed
	)

	if SOCKET_TO_DECORATION.has(
		socket_name
	):

		var stairs: Node = find_node(
			module,
			SOCKET_TO_DECORATION[socket_name]
		)

		if stairs != null:

			set_node_visible(
				stairs,
				not closed
			)


# ============================================================
# BUSCAR CUALQUIER NODO
# ============================================================

func find_node(
	root: Node,
	node_name: String
) -> Node:

	if root == null:
		return null

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


# ============================================================
# VISIBILIDAD
# ============================================================

func set_node_visible(
	node: Node,
	value: bool
):

	if node is CanvasItem:

		var canvas_item: CanvasItem = (
			node as CanvasItem
		)

		canvas_item.visible = value

	if node is TileMapLayer:

		var tilemap: TileMapLayer = (
			node as TileMapLayer
		)

		tilemap.collision_enabled = value


# ============================================================
# LIMPIAR DUNGEON
# ============================================================

func clear_dungeon():

	print(
		"\n[CLEAR] ======================================"
	)

	print(
		"[CLEAR] Hijos del Dungeon: ",
		dungeon.get_child_count()
	)

	for child in dungeon.get_children():

		print(
			"[CLEAR] Eliminando: ",
			child.name
		)

		dungeon.remove_child(child)

		child.queue_free()

	generated_modules.clear()

	occupied_rects.clear()

	pending_sockets.clear()

	print(
		"[CLEAR] generated_modules: ",
		generated_modules.size()
	)

	print(
		"[CLEAR] occupied_rects: ",
		occupied_rects.size()
	)

	print(
		"[CLEAR] pending_sockets: ",
		pending_sockets.size()
	)


# ============================================================
# SALA DEL JEFE
# ============================================================

func lock_boss_room(
	boss_room: Node2D
):

	print(
		"\n[BOSS LOCK] ==============================="
	)

	if not is_instance_valid(
		boss_room
	):

		print(
			"[BOSS LOCK ERROR] BossRoom inválida"
		)

		return

	var entrance: String = (
		boss_room.get_meta(
			"entrance_socket",
			""
		)
	)

	print(
		"[BOSS LOCK] Entrada: ",
		entrance
	)

	if entrance == "":

		push_error(
			"La sala del jefe no tiene 'entrance_socket'."
		)

		return

	set_socket_door_closed(
		boss_room,
		entrance,
		true
	)

	print(
		"Puerta de entrada del jefe cerrada: ",
		entrance
	)


# ============================================================
# COMPLETAR BOSS
# ============================================================

func complete_boss_room(
	boss_room: Node2D
):

	print(
		"\n[BOSS COMPLETE] ==========================="
	)

	if not is_instance_valid(
		boss_room
	):

		print(
			"[BOSS COMPLETE ERROR] BossRoom inválida"
		)

		return

	var entrance: String = (
		boss_room.get_meta(
			"entrance_socket",
			""
		)
	)

	print(
		"[BOSS COMPLETE] Entrada: ",
		entrance
	)

	if entrance != "":

		set_socket_door_closed(
			boss_room,
			entrance,
			false
		)

	var exit_sockets: Array = (
		boss_room.get_meta(
			"exit_sockets",
			[]
		)
	)

	print(
		"[BOSS COMPLETE] Salidas: ",
		exit_sockets
	)

	for socket_name in exit_sockets:

		set_socket_door_closed(
			boss_room,
			socket_name,
			false
		)

		create_exit_trigger(
			boss_room,
			socket_name
		)

	print(
		"Jefe derrotado: puertas abiertas"
	)


# ============================================================
# CREAR EXIT TRIGGER
# ============================================================

func create_exit_trigger(
	boss_room: Node2D,
	socket_name: String
):

	print(
		"\n[EXIT TRIGGER] Creando para: ",
		socket_name
	)

	var socket: Marker2D = find_marker(
		boss_room,
		socket_name
	)

	if socket == null:

		print(
			"[EXIT TRIGGER ERROR] Socket no encontrado"
		)

		return

	var size: Vector2 = exit_trigger_size

	if (
		socket_name == "SocketUp"
		or socket_name == "SocketDown"
	):

		size = Vector2(
			size.y,
			size.x
		)

	var rect: RectangleShape2D = (
		RectangleShape2D.new()
	)

	rect.size = size

	var shape: CollisionShape2D = (
		CollisionShape2D.new()
	)

	shape.shape = rect

	var area: Area2D = Area2D.new()

	area.name = "NextLevelTrigger"

	area.collision_layer = 0

	area.collision_mask = 0xFFFFFFFF

	area.add_child(shape)

	boss_room.add_child(area)

	area.global_position = (
		socket.global_position
	)

	area.body_entered.connect(
		_on_exit_trigger_body_entered
	)

	print(
		"[EXIT TRIGGER] Creado correctamente"
	)


# ============================================================
# EXIT TRIGGER BODY ENTERED
# ============================================================

func _on_exit_trigger_body_entered(
	body: Node2D
):

	print(
		"\n[EXIT TRIGGER] Body detectado: ",
		body.name
	)

	if not body is Player:

		print(
			"[EXIT TRIGGER] No es Player"
		)

		return

	print(
		"[EXIT TRIGGER] PLAYER DETECTADO"
	)

	print(
		"[EXIT TRIGGER] Cargando siguiente nivel..."
	)

	call_deferred(
		"load_next_level"
	)


# ============================================================
# COLISIONES
# ============================================================

func set_collision_state_recursive(
	node: Node,
	enabled: bool
):

	if node is CollisionShape2D:

		node.set_deferred(
			"disabled",
			not enabled
		)

	elif node is CollisionPolygon2D:

		node.set_deferred(
			"disabled",
			not enabled
		)

	elif node is TileMapLayer:

		node.set_deferred(
			"collision_enabled",
			enabled
		)

	for child in node.get_children():

		set_collision_state_recursive(
			child,
			enabled
		)


# ============================================================
# BACKGROUND
# ============================================================

func build_background():

	print(
		"\n[BACKGROUND] ==============================="
	)

	if occupied_rects.is_empty():

		print(
			"[BACKGROUND] No hay rectángulos"
		)

		return

	var bounds: Rect2 = (
		occupied_rects[0]
	)

	for rect in occupied_rects:

		bounds = bounds.merge(
			rect
		)

	print(
		"[BACKGROUND] Bounds finales: ",
		bounds
	)

	var background_data: LevelData = LevelData.new()

	background_data.modules_to_generate = modules_to_generate
	background_data.treasure_room_count = treasure_room_count
	background_data.start_module = start_module
	background_data.room_modules = room_modules
	background_data.corridor_h_modules = corridor_h_modules
	background_data.corridor_v_modules = corridor_v_modules
	background_data.treasure_modules = treasure_modules
	background_data.boss_modules = boss_modules

	background.build(
		bounds,
		background_data
	)

	print(
		"[BACKGROUND] Background construido"
	)
