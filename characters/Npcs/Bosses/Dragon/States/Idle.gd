extends State_base

var dragon: Dragon

@export var idle_time := 0.5

@export_category("Ataques Fase 1")
@export var ataques_fase_1: Array[Dictionary] = [
	{"nombre": "Shoot", "probabilidad": 20.0},
	{"nombre": "Flame", "probabilidad": 15.0},
	{"nombre": "MeteorRain", "probabilidad": 15.0},
	{"nombre": "GarraI", "probabilidad": 15.0},
	{"nombre": "GarraD", "probabilidad": 15.0},
]

@export_category("Ataques Fase 2")
@export var ataques_fase_2: Array[Dictionary] = [
	{"nombre": "Shoot", "probabilidad": 40.0},
	{"nombre": "MeteorRain", "probabilidad": 20.0},
	{"nombre": "Summon", "probabilidad": 40.0},
]


func start() -> void:
	dragon = controlled_node

	print("IDLE - Fase actual: ", dragon.fase)
	print("IDLE - Transición: ", dragon.en_transicion)

	await get_tree().create_timer(idle_time).timeout

	if state_machine.current_state != self:
		return

	if dragon.en_transicion:
		print("IDLE - Sigue en transición")
		return

	elegir_ataque()


func elegir_ataque() -> void:

	print("ELIGIENDO ATAQUE - Fase: ", dragon.fase)

	if dragon.en_transicion:
		print("No puede atacar: transición")
		return

	var ataques: Array[Dictionary]

	if dragon.fase == 1:
		ataques = ataques_fase_1
		print("Usando ataques de FASE 1")

	elif dragon.fase == 2:
		ataques = ataques_fase_2
		print("Usando ataques de FASE 2")
		print("Cantidad de ataques: ", ataques.size())

	else:
		print("Fase desconocida: ", dragon.fase)
		return

	var total: float = 0.0

	for ataque in ataques:
		total += ataque["probabilidad"]

	print("Probabilidad total: ", total)

	if total <= 0.0:
		print("ERROR: no hay probabilidades")
		return

	var random_value := randf_range(0.0, total)

	print("Número aleatorio: ", random_value)

	var acumulado: float = 0.0

	for ataque in ataques:

		acumulado += ataque["probabilidad"]

		if random_value <= acumulado:
			print("ATAQUE ELEGIDO: ", ataque["nombre"])

			state_machine.change_to(ataque["nombre"])
			return


func end() -> void:
	pass
