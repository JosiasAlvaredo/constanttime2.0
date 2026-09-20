extends State_base

var arañalobo

@export var idle_time := 1.0


# Cada ataque tiene:
# ["NombreDelEstado", probabilidad]

@export_category("Ataques Fase 1")

@export var ataques_fase_1: Array[Dictionary] = [
	{"nombre": "Shoot", "probabilidad": 40.0},
	{"nombre": "AttackIzq", "probabilidad": 60.0}
]


@export_category("Ataques Fase 2")

@export var ataques_fase_2: Array[Dictionary] = [
	{"nombre": "Shoot", "probabilidad": 10.0},
	{"nombre": "AttackIzq", "probabilidad": 10.0},
	{"nombre": "Summon", "probabilidad": 80.0},
]


func start() -> void:
	arañalobo = controlled_node

	await get_tree().create_timer(idle_time).timeout

	if state_machine.current_state != self:
		return

	elegir_ataque()


func elegir_ataque() -> void:

	var ataques: Array[Dictionary]


	# Elegimos la lista dependiendo de la fase

	if arañalobo.fase == 1:
		ataques = ataques_fase_1

	elif arañalobo.fase == 2:
		ataques = ataques_fase_2

	else:
		return


	# Calcular la suma de todas las probabilidades

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
