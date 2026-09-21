extends enemy_base
class_name Dragon

@export var plataformas_scene: PackedScene

var playerUbi: Node2D = null

var fase := 1
var vida_inicial := 0.0

var animacion_fase_2_actual := "Fase2A"

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	playerUbi = get_tree().get_first_node_in_group("player")
	vida_inicial = live

	# Animación inicial
	animation_player.play("IdleFase1")


func suffer_damage(_damage) -> void:
	super.suffer_damage(_damage)

	if live <= 0:
		return

	if fase == 1 and live <= vida_inicial / 2.0:
		cambiar_a_fase_2()


func cambiar_a_fase_2() -> void:
	fase = 2

	print("¡DRAGON ENTRA EN FASE 2!")

	# Reproducir transición
	animation_player.play("TransicionFase2")

	# Esperar a que termine
	await animation_player.animation_finished

	if live <= 0:
		return

	# Crear las plataformas después de la transición
	crear_plataformas()

	# Primera animación de fase 2
	animacion_fase_2_actual = "Fase2A"
	animation_player.play(animacion_fase_2_actual)

	# Empezar ciclo de fase 2
	ciclo_fase_2()


func ciclo_fase_2() -> void:

	while fase == 2 and live > 0:

		# Esperar 7 segundos
		await get_tree().create_timer(7.0).timeout

		if fase != 2 or live <= 0:
			return

		elegir_siguiente_animacion()


func elegir_siguiente_animacion() -> void:

	var siguiente_animacion: String

	if animacion_fase_2_actual == "Fase2A":

		# Desde A puede ir a I o D
		if randf() < 0.5:
			siguiente_animacion = "Fase2I"
		else:
			siguiente_animacion = "Fase2D"

	elif animacion_fase_2_actual == "Fase2I":

		# Desde I puede ir a A o D
		if randf() < 0.5:
			siguiente_animacion = "Fase2A"
		else:
			siguiente_animacion = "Fase2D"

	elif animacion_fase_2_actual == "Fase2D":

		# Desde D puede ir a A o I
		if randf() < 0.5:
			siguiente_animacion = "Fase2A"
		else:
			siguiente_animacion = "Fase2I"

	animacion_fase_2_actual = siguiente_animacion

	animation_player.play(siguiente_animacion)


func crear_plataformas() -> void:

	if plataformas_scene == null:
		push_error("No se asignó Plataformas.tscn")
		return

	var spawn_point: Marker2D = get_tree().current_scene.get_node("PlataformasSpawn")

	var plataformas = plataformas_scene.instantiate()

	get_tree().current_scene.add_child(plataformas)

	plataformas.global_position = spawn_point.global_position


func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
