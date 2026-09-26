extends Camera2D

@onready var boss_room_trigger: Area2D = $"../BossRoomTrigger"

var battel_position=position

func _physics_process(delta: float) -> void:
	
	match boss_room_trigger.state:
		boss_room_trigger.State.IDLE:position=$"../Player".position
		boss_room_trigger.State.FIGHTING:
			position.x= move_toward(position.x,battel_position.x,abs(battel_position.x-position.x)/50)
			position.y= move_toward(position.y,battel_position.y,abs(battel_position.y-position.y)/50)
		boss_room_trigger.State.CLEARED:position=$"../Player".position
