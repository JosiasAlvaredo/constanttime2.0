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

	await get_tree().create_timer(idle_time).timeout

	if state_machine.current_state != self:
		return

	if dragon.en_transicion:
		return

	elegir_ataque()


func elegir_ataque() -> void:

	if dragon.en_transicion:
		return

	var ataques: Array[Dictionary]

	if dragon.fase == 1:
		ataques = ataques_fase_1

	elif dragon.fase == 2:
		ataques = ataques_fase_2

	else:
		return

	var total: float = 0.0

	for ataque in ataques:
		total += ataque["probabilidad"]

	if total <= 0.0:
		return

	var random_value := randf_range(0.0, total)
	var acumulado: float = 0.0

	for ataque in ataques:

		acumulado += ataque["probabilidad"]

		if random_value <= acumulado:
			print("🐉 Ataque elegido: ", ataque["nombre"])
			state_machine.change_to(ataque["nombre"])
			return


func end() -> void:
	pass
