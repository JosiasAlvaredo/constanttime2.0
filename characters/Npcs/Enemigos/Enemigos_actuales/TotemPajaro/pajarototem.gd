extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var spread_angle := 20.0

var player: Node2D = null

@onready var shoot_point: Marker2D = $ShootPoint


func shoot():
	if player == null:
		return

	var direction = (player.global_position - shoot_point.global_position).normalized()

	for i in range(4):
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)

		var angle = deg_to_rad(
			-spread_angle / 2.0 + (spread_angle / 3.0) * i
		)

		projectile.global_position = shoot_point.global_position
		projectile.direction = direction.rotated(angle)


func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body


func _on_detection_area_body_exited(body):
	if body == player:
		player = null
