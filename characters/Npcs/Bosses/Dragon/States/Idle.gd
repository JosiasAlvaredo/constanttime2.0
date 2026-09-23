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

	if dragon.en_aparicion:
		return

	print("🟢 IDLE")
	print("🐉 Fase: ", dragon.fase)

	if dragon.fase == 2:
		print("🐉 Posición: ", dragon.posicion_fase_2)

	print("🐉 Posición real: ", dragon.global_position)

	await get_tree().create_timer(idle_time).timeout

	if state_machine.current_state != self:
		return

	if dragon.en_transicion:
		return

	if dragon.en_aparicion:
		return

	elegir_ataque()


func elegir_ataque() -> void:
	if dragon.en_transicion:
		return

	if dragon.en_aparicion:
		return

	var ataques: Array[Dictionary]

	if dragon.fase == 1:
		ataques = ataques_fase_1

	elif dragon.fase == 2:
		ataques = ataques_fase_2

	else:
		print("⚠️ Fase desconocida: ", dragon.fase)
		return

	var total := 0.0

	for ataque in ataques:
		total += ataque["probabilidad"]

	if total <= 0.0:
		print("❌ No hay probabilidades de ataque")
		return

	var random_value := randf_range(0.0, total)
	var acumulado := 0.0

	for ataque in ataques:
		acumulado += ataque["probabilidad"]

		if random_value <= acumulado:
			print("⚔️ ATAQUE ELEGIDO: ", ataque["nombre"])

			if dragon.fase == 2:
				print("🐉 Posición del dragón: ", dragon.posicion_fase_2)

			state_machine.change_to(ataque["nombre"])
			return


func end() -> void:
	pass
