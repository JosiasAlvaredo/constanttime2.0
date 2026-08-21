extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var attack_width := 300.0
@export var attack_height := 300.0
@export var attack_cooldown := 1.5

var cooldown := 0.0


func _physics_process(delta):
	cooldown -= delta

	if cooldown <= 0:
		spawn_projectile()
		cooldown = attack_cooldown


func spawn_projectile():
	var projectile = projectile_scene.instantiate()

	get_parent().add_child(projectile)

	var random_x = randf_range(
		global_position.x - attack_width / 2,
		global_position.x + attack_width / 2
	)

	var from_top = randi() % 2 == 0

	if from_top:
		projectile.global_position = Vector2(
			random_x,
			global_position.y - attack_height
		)

		projectile.direction = 1

	else:
		projectile.global_position = Vector2(
			random_x,
			global_position.y
		)

		projectile.direction = -1
