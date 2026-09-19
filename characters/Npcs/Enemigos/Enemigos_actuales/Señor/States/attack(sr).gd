extends State_base

@export var animation_name := "Attack"


func start() -> void:
	var enemy = controlled_node

	enemy.animation_player.play(animation_name)


func on_physics_process(delta: float) -> void:
	var enemy = controlled_node

	enemy.velocity.x = 0
	enemy.move_and_slide()

	if not enemy.animation_player.is_playing():
		state_machine.change_to("Patrol(Sr)")
