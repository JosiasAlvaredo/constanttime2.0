
extends enemy_base

@export var projectile_scene: PackedScene
@export var spread_angle := 20.0

var playerUbi: Node2D = null

@onready var shoot_point: Marker2D = $ShootPoint
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.scale.x=direction*abs(sprite.scale.x)

func shoot() -> void:
	if playerUbi == null:
		return

	var directionPlayer := (
		playerUbi.global_position - shoot_point.global_position
	).normalized()

	# Mirar hacia donde dispara
	if directionPlayer.x > 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

	for i in range(4):
		var projectile = projectile_scene.instantiate()

		get_parent().add_child(projectile)

		var angle := deg_to_rad(
			-spread_angle / 2.0 + (spread_angle / 3.0) * i
		)

		projectile.global_position = shoot_point.global_position

		projectile.directionPlayer = directionPlayer.rotated(angle)


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		playerUbi = body


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == playerUbi:
		playerUbi = null


func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
