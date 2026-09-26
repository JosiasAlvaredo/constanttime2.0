extends Node2D


signal level_started(level_index: int)
signal game_completed


@export_range(1, 1000, 1) var modules_to_generate: int = 20
@export_range(0, 100, 1) var treasure_room_count: int = 2

@export_enum("Cueva","Alcantarilla","Mazmorra") var level:String

var start_module: Array[PackedScene]

var room_modules: Array[PackedScene] = []
var corridor_h_modules: Array[PackedScene] = []
var corridor_v_modules: Array[PackedScene] = []
var treasure_modules: Array[PackedScene] = []
var boss_modules: Array[PackedScene] = []

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

func _ready() -> void:

	print("\n")
	print("====================================================")
	print("             DUNGEON GENERATOR START")
	print("====================================================")
	print(
		"[GENERATOR] ",
		name,
		" | level = ",
		level,
		" | path = ",
		get_path()
	)
	start_module = load_rooms("res://scenes/Generacion Procedural/%s/start/" % level)

	room_modules = load_rooms("res://scenes/Generacion Procedural/%s/rooms/normal/" % level)
	corridor_v_modules = load_rooms("res://scenes/Generacion Procedural/%s/corridors/vertical/" % level)
	boss_modules = load_rooms("res://scenes/Generacion Procedural/%s/boss/" % level)
	randomize()

	dungeon.z_index = -10

	add_to_group("dungeon_generator")

	print("[READY] Randomize ejecutado")
	print("[READY] Dungeon Z Index: ", dungeon.z_index)
	print("[READY] Módulos solicitados: ", modules_to_generate)
	print("[READY] Tesoros solicitados: ", treasure_room_count)
	print("[READY] Start module: ", start_module)
	print("[READY] Rooms configuradas: ", room_modules.size())
	print("[READY] Corridors H configurados: ", corridor_h_modules.size())
	print("[READY] Corridors V configurados: ", corridor_v_modules.size())
	print("[READY] Treasures configurados: ", treasure_modules.size())
	print("[READY] Bosses configurados: ", boss_modules.size())

	start_level()

func load_rooms(dir)-> Array[PackedScene]:
	
	var foulder = DirAccess.open(dir)
	
	
	
	var escenarios:Array[PackedScene]=[]
	if foulder:
		foulder.list_dir_begin()
		var archivo = foulder.get_next()
		
		while archivo != "":
			if archivo.ends_with(".tscn"):
				escenarios.append(load("%s/%s" % [dir,archivo]))
			
			archivo = foulder.get_next()
		
		foulder.list_dir_end()
	
	return escenarios

# ============================================================
# NIVEL ACTUAL
# ============================================================

func start_level() -> void:

	print("\n")
	print("====================================================")
	print("                 START LEVEL")
	print("====================================================")

	if not validate_level_data():
		print("[LEVEL ERROR] Configuración mínima inválida")
		return

	print("[LEVEL] Configuración válida")

	generate_dungeon()

	print("[LEVEL] Dungeon generada")

	build_background()

	print("[LEVEL] Background construido")

	level_started.emit(current_level_index)

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
		ok = false

	if start_module == null:
		push_error("Falta 'start_module'.")
		ok = false

	if boss_modules.is_empty():
		push_error("'boss_modules' está vacío.")
		ok = false

	# --------------------------------------------------------
	# LAS ROOMS YA NO SON OBLIGATORIAS
	# --------------------------------------------------------

	if get_valid_scenes(room_modules).is_empty():

		print(
			"[VALIDATE WARNING] No hay rooms válidas."
		)

		print(
			"[VALIDATE WARNING] Se usarán únicamente corredores."
		)

	# --------------------------------------------------------
	# LOS TESOROS YA NO SON OBLIGATORIOS
	# --------------------------------------------------------

	if treasure_room_count > 0:

		if get_valid_scenes(treasure_modules).is_empty():

			print(
				"[VALIDATE WARNING] No hay escenas de tesoro válidas."
			)

			print(
				"[VALIDATE WARNING] Los tesoros serán omitidos."
			)

	print("[VALIDATE] Resultado: ", ok)

	return ok


# ============================================================
# OBTENER ESCENAS VÁLIDAS
# ============================================================

func get_valid_scenes(
	scenes: Array[PackedScene]
) -> Array[PackedScene]:

	var valid_scenes: Array[PackedScene] = []

	for scene in scenes:

		if scene == null:
			continue

		valid_scenes.append(scene)

	return valid_scenes


# ============================================================
# CARGAR SIGUIENTE NIVEL
# ============================================================

func load_next_level() -> void:

	print("\n[LEVEL TRANSITION] ===============================")

	if is_transitioning:
		print("[LEVEL TRANSITION] Ya está cambiando de nivel")
		return

	is_transitioning = true

	print("[LEVEL TRANSITION] Emitiendo game_completed")

	game_completed.emit()

	is_transitioning = false


# ============================================================
# GENERACIÓN PRINCIPAL
# ============================================================

func generate_dungeon() -> void:

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

		var module_count: int = result["module_count"]
		var treasures_created: int = result["treasures"]
		var boss_created: bool = result["boss"]

		print("[GENERATION] Módulos: ", module_count)
		print("[GENERATION] Tesoros: ", treasures_created)
		print("[GENERATION] Boss: ", boss_created)

		var enough_modules: bool = module_count > 1
		var has_boss: bool = boss_created

		# ----------------------------------------------------
		# TESOROS
		#
		# Los tesoros NO invalidan una generación.
		# Si faltan escenas o sockets, se omiten.
		# ----------------------------------------------------

		var treasure_requirement_met: bool = true

		if treasure_room_count > 0:

			if get_valid_scenes(treasure_modules).is_empty():

				print(
					"[GENERATION] Tesoros omitidos: no hay escenas válidas."
				)

			else:

				print(
					"[GENERATION] Tesoros creados: ",
					treasures_created,
					"/",
					treasure_room_count
				)

		generation_valid = (
			enough_modules
			and has_boss
			and treasure_requirement_met
		)

		print("[GENERATION] enough_modules: ", enough_modules)
		print("[GENERATION] has_boss: ", has_boss)
		print(
			"[GENERATION] treasure_requirement_met: ",
			treasure_requirement_met
		)

		print(
			"[GENERATION] generation_valid: ",
			generation_valid
		)

		if not generation_valid:

			print("\n[GENERATION] GENERACIÓN DESCARTADA")

			if not enough_modules:
				print("- No se generaron suficientes módulos.")

			if not has_boss:
				print("- No se generó la sala de Boss.")

			clear_dungeon()

	if generation_valid:

		print("\n[GENERATION] Generación válida")

		close_unused_sockets()

		print("[GENERATION] Sockets cerrados")

		print("====================================================")
		print("          MAZMORRA GENERADA CORRECTAMENTE")
		print("====================================================")

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

	if start_module == null:

		print("[ATTEMPT ERROR] start_module es NULL")

		return {
			"module_count": 0,
			"treasures": 0,
			"boss": false
		}

	var start: Node2D = start_module[0].instantiate()

	if start == null:

		print("[ATTEMPT ERROR] No se pudo instanciar StartModule")

		return {
			"module_count": 0,
			"treasures": 0,
			"boss": false
		}

	print("[ATTEMPT] StartModule instanciado: ", start.name)

	dungeon.add_child(start)

	start.position = Vector2.ZERO

	generated_modules.append(start)

	register_module(start)

	print(
		"[ATTEMPT] StartModule registrado"
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

	pending_sockets.append(start_socket)

	print(
		"[START SOCKET] Socket agregado"
	)

	# --------------------------------------------------------
	# GENERAR MÓDULOS NORMALES
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

		print("\n[MODULE LOOP] Intento: ", attempts)

		var socket: Marker2D = select_socket()

		if socket == null:
			print("[MODULE LOOP] No hay socket válido")
			break

		print(
			"[MODULE LOOP] Socket elegido: ",
			socket.name
		)

		var created: bool = create_from_socket(
			socket
		)

		if created:

			remove_pending_socket(socket)

			print(
				"[MODULE LOOP] Módulo creado correctamente"
			)

		else:

			# ------------------------------------------------
			# IMPORTANTE:
			# Si este socket no puede generar nada,
			# se descarta y seguimos con otro.
			# ------------------------------------------------

			print(
				"[MODULE LOOP] Socket inutilizable. "
				+ "Se descarta."
			)

			remove_pending_socket(socket)

	# --------------------------------------------------------
	# TESOROS
	# --------------------------------------------------------

	print("\n")
	print("====================================================")
	print("             GENERANDO TESOROS")
	print("====================================================")

	var treasures_created: int = 0

	var valid_treasure_scenes: Array[PackedScene] = (
		get_valid_scenes(treasure_modules)
	)

	if valid_treasure_scenes.is_empty():

		print(
			"[TREASURE] No existen escenas válidas."
		)

		print(
			"[TREASURE] Se omite generación de tesoros."
		)

	else:

		while (
			treasures_created < treasure_room_count
			and not pending_sockets.is_empty()
			and attempts < MAX_ATTEMPTS
		):

			attempts += 1

			print(
				"\n[TREASURE LOOP] ",
				treasures_created + 1,
				"/",
				treasure_room_count
			)

			var socket: Marker2D = select_socket()

			if socket == null:

				print(
					"[TREASURE] No hay sockets válidos."
				)

				break

			print(
				"[TREASURE] Socket elegido: ",
				socket.name
			)

			var created: bool = create_special_from_socket(
				socket,
				valid_treasure_scenes,
				"TREASURE"
			)

			if created:

				remove_pending_socket(socket)

				treasures_created += 1

				print(
					"[TREASURE] Tesoro creado: ",
					treasures_created,
					"/",
					treasure_room_count
				)

			else:

				print(
					"[TREASURE] Este socket no permite tesoro."
				)

				remove_pending_socket(socket)

		if treasures_created < treasure_room_count:

			print(
				"[TREASURE WARNING] No se pudieron colocar todos."
			)

			print(
				"[TREASURE WARNING] Creados: ",
				treasures_created,
				"/",
				treasure_room_count
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

		print(
			"\n[BOSS LOOP] Intento Boss"
		)

		var socket: Marker2D = select_socket()

		if socket == null:
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

		if boss_created:

			remove_pending_socket(socket)

			print(
				"[BOSS] Boss creado correctamente"
			)

		else:

			print(
				"[BOSS] Socket incompatible. "
				+ "Probando siguiente."
			)

			remove_pending_socket(socket)

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

	if pending_sockets.is_empty():
		return null

	var horizontal: Array[Marker2D] = []
	var vertical: Array[Marker2D] = []

	for socket in pending_sockets:

		if not is_instance_valid(socket):
			continue

		match socket.name:

			"SocketLeft", "SocketRight":
				horizontal.append(socket)

			"SocketUp", "SocketDown":
				vertical.append(socket)

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

	if total_weight <= 0:
		return null

	var value: int = randi_range(
		1,
		total_weight
	)

	if value <= horizontal_weight:

		if horizontal.is_empty():
			return null

		return horizontal.pick_random()

	if vertical.is_empty():

		if not horizontal.is_empty():
			return horizontal.pick_random()

		return null

	return vertical.pick_random()


# ============================================================
# CREAR MÓDULO
# ============================================================

func create_from_socket(
	connection_socket: Marker2D
) -> bool:

	if connection_socket == null:
		return false

	var direction: String = get_socket_direction(
		connection_socket
	)

	if direction == "":
		return false

	var module_types: Array[Dictionary] = []

	# --------------------------------------------------------
	# SOLO AGREGAR TIPOS QUE REALMENTE TIENEN ESCENAS
	# --------------------------------------------------------

	if not get_valid_scenes(room_modules).is_empty():

		module_types.append({
			"type": "ROOM",
			"weight": ROOM_WEIGHT
		})

	if not get_valid_scenes(corridor_h_modules).is_empty():

		module_types.append({
			"type": "CORRIDOR_H",
			"weight": CORRIDOR_H_WEIGHT
		})

	if not get_valid_scenes(corridor_v_modules).is_empty():

		module_types.append({
			"type": "CORRIDOR_V",
			"weight": CORRIDOR_V_WEIGHT
		})

	if module_types.is_empty():

		print(
			"[CREATE] No existen módulos normales disponibles."
		)

		return false

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

	match selected_type:

		"ROOM":
			add_compatible_room(
				candidates,
				direction
			)

		"CORRIDOR_H":
			add_compatible_corridor_h(
				candidates,
				direction
			)

		"CORRIDOR_V":
			add_compatible_corridor_v(
				candidates,
				direction
			)

	# --------------------------------------------------------
	# FALLBACK
	# --------------------------------------------------------

	if candidates.is_empty():

		print(
			"[CREATE] No hay candidatos para ",
			selected_type
		)

		var fallback_types: Array[String] = [
			"ROOM",
			"CORRIDOR_H",
			"CORRIDOR_V"
		]

		fallback_types.shuffle()

		for fallback in fallback_types:

			if fallback == selected_type:
				continue

			candidates.clear()

			match fallback:

				"ROOM":
					add_compatible_room(
						candidates,
						direction
					)

				"CORRIDOR_H":
					add_compatible_corridor_h(
						candidates,
						direction
					)

				"CORRIDOR_V":
					add_compatible_corridor_v(
						candidates,
						direction
					)

			if not candidates.is_empty():

				print(
					"[FALLBACK] Utilizando ",
					fallback
				)

				break

	if candidates.is_empty():

		print(
			"[CREATE] No existe módulo compatible."
		)

		return false

	candidates.shuffle()

	# --------------------------------------------------------
	# PROBAR CANDIDATOS
	# --------------------------------------------------------

	for candidate in candidates:

		var scene: PackedScene = candidate["scene"]
		var input_socket_name: String = candidate["socket"]

		if scene == null:
			continue

		var module: Node2D = scene.instantiate()

		if module == null:
			continue

		dungeon.add_child(module)

		var input_socket: Marker2D = find_marker(
			module,
			input_socket_name
		)

		if input_socket == null:

			print(
				"[CREATE] ",
				module.name,
				" no tiene ",
				input_socket_name,
				". Se omite."
			)

			module.queue_free()

			continue

		align_module(
			module,
			input_socket,
			connection_socket
		)

		if module_overlaps(module):

			print(
				"[CREATE] ",
				module.name,
				" genera solapamiento. Se omite."
			)

			module.queue_free()

			continue

		generated_modules.append(module)

		register_module(module)

		add_module_sockets(
			module,
			input_socket_name
		)

		print(
			"[CREATE SUCCESS] ",
			module.name
		)

		return true

	print(
		"[CREATE] Todos los candidatos fallaron."
	)

	return false


# ============================================================
# ROOM COMPATIBLE
# ============================================================

func add_compatible_room(
	candidates: Array[Dictionary],
	direction: String
) -> void:

	var socket_name: String = get_opposite_socket(
		direction
	)

	if socket_name == "":
		return

	for scene in room_modules:

		if scene == null:
			print("[ROOM] Escena NULL omitida")
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
) -> void:

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
				"[CORRIDOR H] No puede conectarse desde arriba."
			)

			return

	if socket_name == "":
		return

	for scene in corridor_h_modules:

		if scene == null:
			print("[CORRIDOR H] Escena NULL omitida")
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
) -> void:

	var socket_name: String = get_opposite_socket(
		direction
	)

	if socket_name == "":
		return

	for scene in corridor_v_modules:

		if scene == null:
			print("[CORRIDOR V] Escena NULL omitida")
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

	if total <= 0:
		return String(types[0]["type"])

	var value: int = randi_range(
		1,
		total
	)

	for entry in types:

		value -= int(entry["weight"])

		if value <= 0:
			return String(entry["type"])

	return String(types[0]["type"])


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

	return ""


# ============================================================
# CREAR SALA ESPECIAL
# ============================================================

func create_special_from_socket(
	connection_socket: Marker2D,
	scenes: Array[PackedScene],
	type_name: String
) -> bool:

	if connection_socket == null:
		return false

	var valid_scenes: Array[PackedScene] = (
		get_valid_scenes(scenes)
	)

	if valid_scenes.is_empty():

		print(
			"[SPECIAL] No existen escenas válidas para ",
			type_name
		)

		return false

	var direction: String = get_socket_direction(
		connection_socket
	)

	if direction == "":
		return false

	var input_socket_name: String = get_opposite_socket(
		direction
	)

	if input_socket_name == "":
		return false

	var shuffled_scenes: Array[PackedScene] = (
		valid_scenes.duplicate()
	)

	shuffled_scenes.shuffle()

	for scene in shuffled_scenes:

		if scene == null:
			continue

		var module: Node2D = scene.instantiate()

		if module == null:
			continue

		dungeon.add_child(module)

		var input_socket: Marker2D = find_marker(
			module,
			input_socket_name
		)

		if input_socket == null:

			print(
				"[SPECIAL] ",
				module.name,
				" no tiene ",
				input_socket_name,
				". Se omite."
			)

			module.queue_free()

			continue

		align_module(
			module,
			input_socket,
			connection_socket
		)

		if module_overlaps(module):

			print(
				"[SPECIAL] ",
				module.name,
				" genera solapamiento. Se omite."
			)

			module.queue_free()

			continue

		generated_modules.append(module)

		register_module(module)

		if type_name == "BOSS":

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

				if socket_name == input_socket_name:
					continue

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

		add_terminal_sockets(
			module,
			input_socket_name
		)

		print(
			"[SPECIAL SUCCESS] ",
			type_name,
			" -> ",
			module.name
		)

		return true

	return false


# ============================================================
# AGREGAR SOCKETS
# ============================================================

func add_module_sockets(
	module: Node2D,
	used_socket: String
) -> void:

	if is_room(module):

		add_room_sockets(
			module,
			used_socket
		)

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

		return

	print(
		"[ADD SOCKETS WARNING] Tipo desconocido: ",
		module.scene_file_path
	)


# ============================================================
# ROOM SOCKETS
# ============================================================

func add_room_sockets(
	room: Node2D,
	used_socket: String
) -> void:

	for socket_name in ALL_SOCKET_NAMES:

		if socket_name == used_socket:
			continue

		var socket: Marker2D = find_marker(
			room,
			socket_name
		)

		if socket != null:
			pending_sockets.append(socket)


# ============================================================
# CORRIDOR H SOCKETS
# ============================================================

func add_horizontal_sockets(
	corridor: Node2D,
	used_socket: String
) -> void:

	var allowed: Array[String] = [
		"SocketLeft",
		"SocketRight",
		"SocketDown"
	]

	for socket_name in allowed:

		if socket_name == used_socket:
			continue

		var socket: Marker2D = find_marker(
			corridor,
			socket_name
		)

		if socket != null:
			pending_sockets.append(socket)


# ============================================================
# CORRIDOR V SOCKETS
# ============================================================

func add_vertical_sockets(
	corridor: Node2D,
	used_socket: String
) -> void:

	for socket_name in ALL_SOCKET_NAMES:

		if socket_name == used_socket:
			continue

		var socket: Marker2D = find_marker(
			corridor,
			socket_name
		)

		if socket != null:
			pending_sockets.append(socket)


# ============================================================
# SOCKETS TERMINALES
# ============================================================

func add_terminal_sockets(
	module: Node2D,
	used_socket: String
) -> void:

	for socket_name in ALL_SOCKET_NAMES:

		if socket_name == used_socket:
			continue

		var socket: Marker2D = find_marker(
			module,
			socket_name
		)

		if socket != null:
			pending_sockets.append(socket)


# ============================================================
# ALINEAR
# ============================================================

func align_module(
	module: Node2D,
	module_socket: Marker2D,
	target_socket: Marker2D
) -> void:

	var offset: Vector2 = (
		target_socket.global_position
		- module_socket.global_position
	)

	module.global_position += offset


# ============================================================
# DIRECCIÓN
# ============================================================

func get_socket_direction(
	socket: Marker2D
) -> String:

	if socket == null:
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

	return ""


# ============================================================
# BUSCAR MARKER
# ============================================================

func find_marker(
	root: Node,
	marker_name: String
) -> Marker2D:

	if root == null:
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

	if is_horizontal_corridor(module):

		var polygon_node: CollisionPolygon2D = (
			find_collision_polygon(module)
		)

		if polygon_node == null:
			return Rect2()

		if polygon_node.polygon.is_empty():
			return Rect2()

		var first_point: Vector2 = (
			polygon_node.global_transform
			* polygon_node.polygon[0]
		)

		var rect: Rect2 = Rect2(
			first_point,
			Vector2.ZERO
		)

		for point in polygon_node.polygon:

			var global_point: Vector2 = (
				polygon_node.global_transform
				* point
			)

			rect = rect.expand(
				global_point
			)

		return rect

	var bounds: CollisionShape2D = (
		find_collision_shape(module)
	)

	if bounds == null:
		return Rect2()

	if bounds.shape == null:
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


# ============================================================
# REGISTRAR
# ============================================================

func register_module(
	module: Node2D
) -> void:

	var rect: Rect2 = (
		get_module_rect(module)
	)

	if rect.size == Vector2.ZERO:

		print(
			"[REGISTER WARNING] Bounds inválidos: ",
			module.name
		)

		return

	occupied_rects.append(rect)


# ============================================================
# REMOVER SOCKET
# ============================================================

func remove_pending_socket(
	socket: Marker2D
) -> void:

	if socket == null:
		return

	var index: int = pending_sockets.find(
		socket
	)

	if index >= 0:
		pending_sockets.remove_at(index)


# ============================================================
# CERRAR PUERTAS
# ============================================================

func close_unused_sockets() -> void:

	for module in generated_modules:

		if not is_instance_valid(module):
			continue

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
) -> void:

	if not SOCKET_TO_DOOR.has(
		socket_name
	):
		return

	var door: Node = find_node(
		module,
		SOCKET_TO_DOOR[socket_name]
	)

	if door == null:
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
) -> void:

	if node is CanvasItem:

		(node as CanvasItem).visible = value

	if node is TileMapLayer:

		(node as TileMapLayer).collision_enabled = value


# ============================================================
# LIMPIAR DUNGEON
# ============================================================

func clear_dungeon() -> void:

	for child in dungeon.get_children():

		dungeon.remove_child(child)

		child.queue_free()

	generated_modules.clear()
	occupied_rects.clear()
	pending_sockets.clear()


# ============================================================
# SALA DEL JEFE
# ============================================================

func lock_boss_room(
	boss_room: Node2D
) -> void:

	if not is_instance_valid(boss_room):
		return

	var entrance: String = (
		boss_room.get_meta(
			"entrance_socket",
			""
		)
	)

	if entrance == "":
		return

	set_socket_door_closed(
		boss_room,
		entrance,
		true
	)


# ============================================================
# COMPLETAR BOSS
# ============================================================

func complete_boss_room(
	boss_room: Node2D
) -> void:

	if not is_instance_valid(boss_room):
		return

	var entrance: String = (
		boss_room.get_meta(
			"entrance_socket",
			""
		)
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


# ============================================================
# CREAR EXIT TRIGGER
# ============================================================

func create_exit_trigger(
	boss_room: Node2D,
	socket_name: String
) -> void:

	var socket: Marker2D = find_marker(
		boss_room,
		socket_name
	)

	if socket == null:
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


# ============================================================
# EXIT TRIGGER BODY ENTERED
# ============================================================

func _on_exit_trigger_body_entered(
	body: Node2D
) -> void:

	if not body is Player:
		return

	call_deferred(
		"load_next_level"
	)


# ============================================================
# COLISIONES
# ============================================================

func set_collision_state_recursive(
	node: Node,
	enabled: bool
) -> void:

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

func build_background() -> void:

	if occupied_rects.is_empty():
		return

	var bounds: Rect2 = occupied_rects[0]

	for rect in occupied_rects:

		bounds = bounds.merge(
			rect
		)

	var background_data: LevelData = LevelData.new()

	background_data.modules_to_generate = modules_to_generate
	background_data.treasure_room_count = treasure_room_count
	background_data.start_module = start_module[0]
	background_data.room_modules = room_modules
	background_data.corridor_h_modules = corridor_h_modules
	background_data.corridor_v_modules = corridor_v_modules
	background_data.treasure_modules = treasure_modules
	background_data.boss_modules = boss_modules

	background.build(
		bounds,
		background_data
	)
