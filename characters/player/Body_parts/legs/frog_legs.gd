extends Node2D

@onready var foot_position: Node2D = $foot_position
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if get_parent().parent.velocity.x!=0 and get_parent().parent.is_on_floor():
		get_parent().parent.velocity.y=get_parent().skills.jump_force*0.65
		animated_sprite_2d.play("jump")
