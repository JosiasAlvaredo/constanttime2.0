extends Node2D
class_name Boss_SweepAttackI

var boss: Boss

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area2D = $Hitbox


func start() -> void:
	hitbox.monitoring = false
	animation_player.play("sweepI")


func finish() -> void:
	hitbox.monitoring = false
	
	if boss:
		boss.state_machine.change_to("Idle")
