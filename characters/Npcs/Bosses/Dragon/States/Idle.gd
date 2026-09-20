extends State_base

var dragon: Dragon
var timer := 0.0

@export var idle_time := 2.0

@export_range(0.0, 100.0) var shoot_chance := 60.0
@export_range(0.0, 100.0) var flame_chance := 40.0


func start() -> void:
	dragon = controlled_node
	timer = 0.0


func on_process(delta: float) -> void:
	timer += delta
	
	if timer >= idle_time:
		choose_attack()


func choose_attack() -> void:
	var random_number := randf_range(0.0, 100.0)
	
	if random_number < shoot_chance:
		state_machine.change_to("Shoot")
	else:
		state_machine.change_to("Flame")


func end() -> void:
	pass
