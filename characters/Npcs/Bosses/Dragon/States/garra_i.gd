extends State_base

var dragon: Dragon


func start() -> void:
	dragon = controlled_node
	
	dragon.animation_player.play("AttackI")


func on_physics_process(_delta: float) -> void:
	if not dragon.animation_player.is_playing():
		state_machine.change_to("Idle")
