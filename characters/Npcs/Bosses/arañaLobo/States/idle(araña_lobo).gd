extends State_base

var boss: Boss
var timer := 0.0


func start() -> void:
	boss = controlled_node
	timer = 0.0
	boss.animation_player.play("idle")


func on_process(delta: float) -> void:
	timer += delta
	
	if timer >= 2.0:
		boss.choose_next_attack()


func end() -> void:
	pass
