extends State_base

var dragon: Dragon

@export var idle_time := 2.0

@export_category("Ataques Fase 1")

@export var ataques_fase_1: Array[Dictionary] = [
	{"nombre": "Shoot", "probabilidad": 30.0},
	{"nombre": "Flame", "probabilidad": 15.0},
	{"nombre": "MeteorRain", "probabilidad": 15.0},
	{"nombre": "GarraI", "probabilidad": 30.0},
]

@export_category("Ataques Fase 2")

@export var ataques_fase_2: Array[Dictionary] = [
	{"nombre": "Shoot", "probabilidad": 0.0},
	{"nombre": "MeteorRain", "probabilidad": 0.0},
	{"nombre": "Summon", "probabilidad": 100.0},
]


func start() -> void:
	dragon = controlled_node

	await get_tree().create_timer(idle_time).timeout

	if state_machine.current_state != self:
		return

	# Si está haciendo la transición de fase, no atacar
	if dragon.en_transicion:
		return

	elegir_ataque()


func elegir_ataque() -> void:

	# Seguridad extra: no elegir ataques durante la transición
	if dragon.en_transicion:
		return

	var ataques: Array[Dictionary]

	# Elegir la lista dependiendo de la fase

	if dragon.fase == 1:
		ataques = ataques_fase_1

	elif dragon.fase == 2:
		ataques = ataques_fase_2

	else:
		return

	# Calcular el total de probabilidades

	var total: float = 0.0

	for ataque in ataques:
		total += ataque["probabilidad"]

	if total <= 0.0:
		return

	# Elegir un número aleatorio

	var random_value := randf_range(0.0, total)

	# Buscar qué ataque corresponde

	var acumulado: float = 0.0

	for ataque in ataques:

		acumulado += ataque["probabilidad"]

		if random_value <= acumulado:
			state_machine.change_to(ataque["nombre"])
			return


func end() -> void:
	pass
