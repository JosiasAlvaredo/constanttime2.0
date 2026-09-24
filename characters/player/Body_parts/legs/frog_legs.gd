extends Node2D

@onready var foot_position: Node2D = $foot_position
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if get_parent().parent.velocity.x!=0 and get_parent().parent.is_on_floor():
		get_parent().parent.state_machine.change_to("Jump")
		get_parent().parent.velocity.y*=0.5
