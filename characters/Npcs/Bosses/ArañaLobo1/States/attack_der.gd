extends State_base

var arañalobo

@export var animation_name := "ClavarD"


func start() -> void:
	arañalobo = controlled_node

	if arañalobo == null:
		push_error("AttackAnimation: arañalobo es null")
		return

	var animation_player: AnimationPlayer = arañalobo.get_node("AnimationPlayer")

	if animation_player == null:
		push_error("AttackAnimation: no se encontró AnimationPlayer")
		state_machine.change_to("Idle")
		return

	animation_player.play(animation_name)

	await animation_player.animation_finished

	if state_machine.current_state != self:
		return

	state_machine.change_to("Idle")


func end() -> void:
	pass
