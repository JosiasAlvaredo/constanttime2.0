extends State_base

@onready var boss_room_trigger: Area2D = $"../../../BossRoomTrigger"
func start():
	await get_tree().create_timer(0.2).timeout
	controlled_node.core_back.play("core")
	controlled_node.core_front.play("core")
	
	for wall in controlled_node.walls:
		wall.play("default")
	if boss_room_trigger.state==boss_room_trigger.State.FIGHTING:
		await get_tree().create_timer(randf_range(10,20)).timeout
		
		var probabily=randf_range(0,100)
		
		if probabily<30:
			state_machine.change_to("Blast")
		else:
			state_machine.change_to("shot_balls")
