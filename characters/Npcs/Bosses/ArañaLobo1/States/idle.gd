extends State_base

var arañalobo

@export var idle_time := 1.0


@export_category("Ataques Fase 1")

@export var ataques_fase_1: Array[Dictionary] = [
	{"nombre": "Shoot", "probabilidad": 30.0},
	{"nombre": "AttackIzq", "probabilidad": 20.0},
	{"nombre": "AttackDer", "probabilidad": 20.0},
	{"nombre": "Summon", "probabilidad": 10.0},
	{"nombre": "Summon2", "probabilidad": 20.0},
]


@export_category("Ataques Fase 2")

@export var ataques_fase_2: Array[Dictionary] = [
	{"nombre": "AttackIzq", "probabilidad": 20.0},
	{"nombre": "AttackDer", "probabilidad": 20.0},
	{"nombre": "Summon", "probabilidad": 20.0},
	{"nombre": "Summon2", "probabilidad": 20.0},
	{"nombre": "AvanicoI", "probabilidad": 10.0},
	{"nombre": "AvanicoD", "probabilidad": 10.0},
]


func start() -> void:
	arañalobo = controlled_node

	if arañalobo.durmiendo:
		return

	if arañalobo.apareciendo:
		return

	if arañalobo.muriendo:
		return

	await get_tree().create_timer(idle_time).timeout

	if state_machine.current_state != self:
		return

	if arañalobo.durmiendo:
		return

	if arañalobo.apareciendo:
		return

	if arañalobo.muriendo:
		return

	if not arañalobo.activada:
		return

	elegir_ataque()


func elegir_ataque() -> void:

	if arañalobo.durmiendo:
		return

	if arañalobo.apareciendo:
		return

	if arañalobo.muriendo:
		return

	if not arañalobo.activada:
		return

	var ataques: Array[Dictionary]

	if arañalobo.fase == 1:
		ataques = ataques_fase_1

	elif arañalobo.fase == 2:
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

			if arañalobo.durmiendo:
				return

			if arañalobo.apareciendo:
				return

			if arañalobo.muriendo:
				return

			state_machine.change_to(ataque["nombre"])
			return


func end() -> void:
	pass
