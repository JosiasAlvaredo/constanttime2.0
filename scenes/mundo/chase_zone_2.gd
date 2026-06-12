extends Area2D

@export var enemy: CharacterBody2D


func _on_body_entered(body):

	if body.name == "Player":

		enemy.player_in_chase_zone = true


func _on_body_exited(body):

	if body.name == "Player":

		enemy.player_in_chase_zone = false
		enemy.player = null
