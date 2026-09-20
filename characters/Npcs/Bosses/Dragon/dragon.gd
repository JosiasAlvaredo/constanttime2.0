extends enemy_base
class_name Dragon

var playerUbi: Node2D = null

var fase := 1
var vida_inicial := 0.0


func _ready() -> void:
	playerUbi = get_tree().get_first_node_in_group("player")
	vida_inicial = live


func suffer_damage(_damage) -> void:
	super.suffer_damage(_damage)

	if live <= 0:
		return

	# Pasar a fase 2 al llegar a la mitad de vida
	if fase == 1 and live <= vida_inicial / 2.0:
		cambiar_a_fase_2()


func cambiar_a_fase_2() -> void:
	fase = 2

	print("¡DRAGON ENTRA EN FASE 2!")

	state_machine.change_to("Idle")
