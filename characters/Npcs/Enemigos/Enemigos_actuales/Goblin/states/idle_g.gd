extends State_base


func start() -> void:
	var enemy = controlled_node
	
	enemy.velocity.x = 0


func on_physics_process(delta: float) -> void:
	var enemy = controlled_node
	
	enemy.velocity.x = 0
	
	if enemy.is_player_in_range():
		state_machine.change_to("ChaseG")
