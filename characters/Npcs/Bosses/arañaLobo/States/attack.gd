extends State_base

var boss: Boss


func start() -> void:
	boss = controlled_node
	
	var attack := boss.attack_manager.choose_attack()
	boss.attack_manager.start_attack(attack)


func end() -> void:
	pass
