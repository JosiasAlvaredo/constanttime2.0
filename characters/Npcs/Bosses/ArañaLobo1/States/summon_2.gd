extends State_base

var arañalobo

@export var enemy_scene: PackedScene
@export var amount := 5
@export var time_between_summons := 0.4

@export var spawn_range_x := 200.0
@export var spawn_range_y := 100.0

var summoning := false


func start() -> void:
	arañalobo = controlled_node
	summoning = true

	if enemy_scene == null:
		push_error("❌ No se asignó el enemigo en Summon")
		state_machine.change_to("Idle")
		return

	summon_enemies()


func summon_enemies() -> void:
	var summon_point: Marker2D = arañalobo.get_node("SummonPoint3")

	for i in range(amount):
		if not summoning:
			return

		invocar_enemigo(summon_point)

		await get_tree().create_timer(time_between_summons).timeout

	summoning = false
	state_machine.change_to("Idle")


func invocar_enemigo(summon_point: Marker2D) -> void:
	var enemigo = enemy_scene.instantiate()

	get_tree().current_scene.add_child(enemigo)

	var offset_x := randf_range(-spawn_range_x, spawn_range_x)
	var offset_y := randf_range(-spawn_range_y, spawn_range_y)

	enemigo.global_position = summon_point.global_position + Vector2(offset_x, offset_y)

	if "playerUbi" in enemigo:
		enemigo.playerUbi = arañalobo.playerUbi


func end() -> void:
	summoning = false
