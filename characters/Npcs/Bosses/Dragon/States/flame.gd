extends State_base

var dragon: Dragon

@export var flame_scene: PackedScene
@export var flame_duration := 2.0

var flame = null
var timer := 0.0


func start() -> void:
	dragon = controlled_node
	timer = 0.0

	if flame_scene == null:
		push_error("No se asignó la escena Flame")
		state_machine.change_to("Idle")
		return

	if dragon.playerUbi == null:
		state_machine.change_to("Idle")
		return

	var shoot_point: Marker2D = dragon.get_node("ShootPoint")

	# Crear Flame
	flame = flame_scene.instantiate()
	get_tree().current_scene.add_child(flame)

	# Posición inicial
	flame.global_position = shoot_point.global_position

	# Guardar la posición del jugador AL INICIAR el ataque
	var player_position := dragon.playerUbi.global_position

	# Dirección hacia esa posición
	var direction := (
		player_position - shoot_point.global_position
	).normalized()

	# Pasarle los datos al Flame
	flame.direction_player = direction
	flame.player_position = player_position


func on_process(delta: float) -> void:
	timer += delta

	if timer >= flame_duration:
		state_machine.change_to("Idle")


func end() -> void:
	if is_instance_valid(flame):
		flame.finish_flame()

	flame = null
