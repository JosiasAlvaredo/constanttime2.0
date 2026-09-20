extends State_base

var dragon: Dragon

@export var meteor_scene: PackedScene

@export var rain_duration := 3.0
@export var time_between_meteors := 0.25

@export var spawn_range := 300.0
@export var spawn_height := 500.0

@export var horizontal_speed := 150.0

var timer := 0.0
var spawn_timer := 0.0

var spawn_point: Marker2D


func start() -> void:
	dragon = controlled_node

	timer = 0.0
	spawn_timer = 0.0

	spawn_point = dragon.get_node("MeteorSpawn")


func on_process(delta: float) -> void:
	timer += delta
	spawn_timer += delta

	if spawn_timer >= time_between_meteors:
		spawn_timer = 0.0
		spawn_meteor()

	if timer >= rain_duration:
		state_machine.change_to("Idle")


func spawn_meteor() -> void:

	if meteor_scene == null:
		return

	var meteor = meteor_scene.instantiate()

	get_tree().current_scene.add_child(meteor)

	# Posición horizontal aleatoria
	var random_x := randf_range(
		-spawn_range,
		spawn_range
	)

	# Aparece arriba del Marker
	meteor.global_position = spawn_point.global_position + Vector2(
		random_x,
		-spawn_height
	)

	# Dirección horizontal aleatoria
	meteor.velocity.x = randf_range(
		-horizontal_speed,
		horizontal_speed
	)


func end() -> void:
	pass
