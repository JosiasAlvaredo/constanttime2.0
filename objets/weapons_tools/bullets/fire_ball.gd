extends CharacterBody2D

@export var skills=null
@export var player=null

func _on_area_2d_area_entered(area: Area2D) -> void:
	await get_tree().create_timer(1).timeout



func _on_area_2d_body_entered(body: Node2D) -> void:
	await get_tree().create_timer(1).timeout


func _physics_process(delta: float) -> void:
	
	move_and_slide()
