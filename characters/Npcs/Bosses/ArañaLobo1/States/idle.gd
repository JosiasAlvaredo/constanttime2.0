extends State_base

var arañalobo

@export var idle_time := 1.0

@export_range(0.0, 100.0) var shoot_chance := 40.0
@export_range(0.0, 100.0) var summon_chance := 10.0
@export_range(0.0, 100.0) var zarpazo_izquierdo_chance := 50.0
@export_range(0.0, 100.0) var zarpazo_derecho_chance := 00.0


func start() -> void:
	arañalobo = controlled_node

	await get_tree().create_timer(idle_time).timeout

	if state_machine.current_state != self:
		return

	choose_attack()


func choose_attack() -> void:
	var total := (
		shoot_chance
		+ summon_chance
		+ zarpazo_izquierdo_chance
		+ zarpazo_derecho_chance
	)

	if total <= 0.0:
		return

	var random_value := randf_range(0.0, total)

	if random_value < shoot_chance:
		state_machine.change_to("Shoot")

	elif random_value < shoot_chance + summon_chance:
		state_machine.change_to("Summon")

	elif random_value < shoot_chance + summon_chance + zarpazo_izquierdo_chance:
		state_machine.change_to("AttackIzq")

	else:
		state_machine.change_to("ZarpazoDerecho")


func end() -> void:
	pass
