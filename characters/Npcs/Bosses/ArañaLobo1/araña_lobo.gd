extends boss_base
class_name ArañaLobo

var playerUbi: Node2D = null

var fase := 1
var vida_inicial := 0.0

var activada := false
var durmiendo := true
var apareciendo := false
var muriendo := false

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var ready_area: Area2D = $ReadyArea


func _ready() -> void:
	playerUbi = get_tree().get_first_node_in_group("player")
	vida_inicial = live

	activada = false
	durmiendo = true
	apareciendo = false
	muriendo = false

	ready_area.monitoring = true
	ready_area.body_entered.connect(_on_ready_area_body_entered)

	animation_player.play("Durmiendo")

	print("🕷️ ArañaLobo esperando al jugador")
	print("🟢 ReadyArea encontrado: ", ready_area)
	print("🟢 Monitoring: ", ready_area.monitoring)


func suffer_damage(_damage) -> void:
	if muriendo:
		return

	if _damage is int:
		damage_efect()
		live -= _damage

		if live <= 0:
			muerte()
			return

	if fase == 1 and live <= vida_inicial / 2.0:
		cambiar_a_fase_2()


func muerte() -> void:
	if muriendo:
		return

	muriendo = true
	durmiendo = false
	apareciendo = false

	print("💀 ARAÑALOBO MURIÓ")

	animation_player.play("Muerte")

	await animation_player.animation_finished

	queue_free()


func cambiar_a_fase_2() -> void:
	if muriendo:
		return

	fase = 2

	print("🕷️ ARAÑALOBO ENTRA EN FASE 2")

	if activada and not durmiendo and not apareciendo:
		state_machine.change_to("Idle")


func _on_ready_area_body_entered(body: Node2D) -> void:
	print("🟡 READY AREA DETECTÓ: ", body.name)

	if activada or muriendo:
		return

	if not body.is_in_group("player"):
		print("❌ No es el jugador")
		return

	activada = true
	durmiendo = false
	apareciendo = true

	print("🕷️ COMIENZA APARICIÓN")

	animation_player.play("Aparicion")

	await animation_player.animation_finished

	if muriendo:
		return

	apareciendo = false

	print("🕷️ TERMINÓ APARICIÓN")

	animation_player.play("Idle")

	state_machine.change_to("Idle")


func _on_area_2d_area_entered(area: Area2D) -> void:
	if muriendo or durmiendo or apareciendo:
		return

	enemy_damage(area.get_parent())
