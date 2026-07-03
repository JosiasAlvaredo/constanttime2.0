extends Area2D

@export var enemy: CharacterBody2D


func _on_body_entered(body):

	if body.is_in_group("player"):

		enemy.player = body
		enemy.player_in_chase_zone = true
		enemy.state = enemy.State.CHASE


func _on_body_exited(body):

	if body.is_in_group("player"):

		enemy.player_in_chase_zone = false
		enemy.state = enemy.State.RETURN
