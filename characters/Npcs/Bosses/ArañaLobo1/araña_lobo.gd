extends boss_base

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

	if fase == 1 and live <= vida_inicial / 2.0:
		cambiar_a_fase_2()


func cambiar_a_fase_2() -> void:
	fase = 2

	print("¡ARAÑALOBO ENTRA EN FASE 2!")

	state_machine.change_to("Idle")


func _on_hitbox_cabeza_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())


func _on_hitbox_izq_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())


func _on_hitbox_der_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
