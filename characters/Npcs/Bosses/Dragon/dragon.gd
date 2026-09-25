extends boss_base
class_name Dragon

@export var plataformas_scene: PackedScene
@export var plataformas_spawn: Marker2D

var playerUbi: Node2D = null

var en_transicion := false
var en_aparicion := true
var aparicion_iniciada := false
var muriendo := false

var fase := 1
var vida_inicial := 0.0

var posicion_fase_2 := "Fase2A"
var animacion_fase_2_actual := "Fase2A"

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	playerUbi = get_tree().get_first_node_in_group("player")
	vida_inicial = live

	en_aparicion = true
	muriendo = false


func _on_ready_area_body_entered(body: Node2D) -> void:
	if aparicion_iniciada:
		return

	if muriendo:
		return

	if body.is_in_group("player"):
		aparicion_iniciada = true
		aparicion()


func aparicion() -> void:
	if muriendo:
		return

	en_aparicion = true

	print("🐉 COMIENZA APARICIÓN")

	animation_player.play("Aparicion")

	await animation_player.animation_finished

	if live <= 0 or muriendo:
		return

	print("🐉 TERMINÓ APARICIÓN")

	animation_player.play("IdleFase1")

	en_aparicion = false

	state_machine.change_to("Idle")


func suffer_damage(_damage) -> void:
	# Si ya está muriendo, no recibe más daño
	if muriendo:
		return

	# Aplicamos el daño manualmente para evitar boss_base.dead()
	if _damage is int:
		damage_efect()
		live -= _damage

		print("🐉 Vida: ", live)

		# Murió
		if live <= 0:
			muerte()
			return

	# Cambio a fase 2
	if fase == 1 and live <= vida_inicial / 2.0:
		cambiar_a_fase_2()


func muerte() -> void:
	if muriendo:
		return

	muriendo = true
	en_aparicion = false
	en_transicion = false

	print("💀 DRAGÓN MURIÓ")

	# Detiene cualquier ataque/animación anterior
	animation_player.stop()

	# Reproduce la animación de muerte
	animation_player.play("Muere")

	await animation_player.animation_finished

	# Desaparece después de terminar la animación
	queue_free()


func cambiar_a_fase_2() -> void:
	if en_transicion:
		return

	if muriendo:
		return

	fase = 2
	en_transicion = true

	print("🔥 DRAGÓN ENTRA EN FASE 2")

	animation_player.play("TransicionFase2")

	await animation_player.animation_finished

	if live <= 0 or muriendo:
		return

	print("🔥 TERMINÓ LA TRANSICIÓN")

	crear_plataformas()

	posicion_fase_2 = "Fase2A"
	animacion_fase_2_actual = "Fase2A"

	print("🐉 POSICIÓN INICIAL: ", posicion_fase_2)
	print("🐉 POSICIÓN REAL: ", global_position)

	animation_player.play("Fase2A")

	en_transicion = false

	state_machine.change_to("Idle")

	ciclo_posiciones_fase_2()


func ciclo_posiciones_fase_2() -> void:
	while fase == 2 and live > 0 and not muriendo:
		await get_tree().create_timer(7.0).timeout

		if fase != 2 or live <= 0 or muriendo:
			return

		cambiar_posicion_fase_2()


func cambiar_posicion_fase_2() -> void:
	if muriendo:
		return

	var siguiente_animacion := ""

	if posicion_fase_2 == "Fase2A":
		if randf() < 0.5:
			siguiente_animacion = "Fase2I"
		else:
			siguiente_animacion = "Fase2D"

	elif posicion_fase_2 == "Fase2I":
		if randf() < 0.5:
			siguiente_animacion = "Fase2A"
		else:
			siguiente_animacion = "Fase2D"

	elif posicion_fase_2 == "Fase2D":
		if randf() < 0.5:
			siguiente_animacion = "Fase2A"
		else:
			siguiente_animacion = "Fase2I"

	else:
		siguiente_animacion = "Fase2A"

	posicion_fase_2 = siguiente_animacion
	animacion_fase_2_actual = siguiente_animacion

	print("🐉 CAMBIANDO POSICIÓN")
	print("🐉 Nueva posición: ", posicion_fase_2)
	print("🐉 Posición real: ", global_position)

	animation_player.play(siguiente_animacion)


func crear_plataformas() -> void:
	if plataformas_scene == null:
		push_error("❌ No se asignó Plataformas.tscn")
		return

	if plataformas_spawn == null:
		push_error("❌ No se asignó PlataformasSpawn")
		return

	var plataformas = plataformas_scene.instantiate()

	get_tree().current_scene.add_child(plataformas)

	plataformas.global_position = plataformas_spawn.global_position


func _on_hitbox_area_entered(area: Area2D) -> void:
	if muriendo:
		return

	enemy_damage(area.get_parent())


func hurtbox_maniIzq(area: Area2D) -> void:
	if muriendo:
		return

	enemy_damage(area.get_parent())


func _on_hurt_box_d_area_entered(area: Area2D) -> void:
	if muriendo:
		return

	enemy_damage(area.get_parent())


func FASE2I(area: Area2D) -> void:
	if muriendo:
		return

	enemy_damage(area.get_parent())


func FASE2D(area: Area2D) -> void:
	if muriendo:
		return

	enemy_damage(area.get_parent())
