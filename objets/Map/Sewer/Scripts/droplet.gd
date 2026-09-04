extends RigidBody2D
@export var probably=10

@export var knockback=Vector2(-200,-100)

@export var damage=5

func _on_hit_box_body_entered(body: Node2D) -> void:
	if randf_range(0, 100)<=probably:
		var new_slime=preload("res://characters/Npcs/Enemigos/Enemigos_actuales/Slime/Slime.tscn").instantiate()
		new_slime.global_position=global_position
		get_parent().get_parent().add_child(new_slime)
	queue_free()
