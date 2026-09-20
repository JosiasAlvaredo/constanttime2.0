extends Node2D

@onready var foot_position: Node2D = $foot_position

func _physics_process(delta: float) -> void:
	if get_parent().parent.velocity.x!=0 and get_parent().parent.is_on_floor():
		get_parent().parent.velocity.y=get_parent().skills.jump_force*0.65
