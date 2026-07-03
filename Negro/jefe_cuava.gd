extends enemy_base

@export var projectile_scene: PackedScene
@export var move_distance: float = 200.0
@export var move_speed: float = 100.0

@onready var timer: Timer = $Timer
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var activated := false
var waking_up := false
var is_shooting := false

var start_x: float


func _ready():
	player = get_tree().get_first_node_in_group("player")
	start_x = global_position.x
	animated_sprite_2d.play("sleep")


func _physics_process(delta):

	# Mientras está dormido
	if !activated:
		if !waking_up and animated_sprite_2d.animation != "sleep":
			animated_sprite_2d.play("sleep")
		return

	# Animación de caminar
	if animated_sprite_2d.animation != "walk":
		animated_sprite_2d.play("walk")

	# Movimiento
	velocity.x = direction * move_speed

	if global_position.x >= start_x + move_distance:
		direction = -1
	elif global_position.x <= start_x - move_distance:
		direction = 1

	move_and_slide()

	# Girar sprite
	animated_sprite_2d.flip_h = direction == -1

	# Actualizar RayCast
	if player:
		ray_cast_2d.target_position = ray_cast_2d.to_local(player.global_position)

	# Disparo
	if !is_shooting and ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()

		if collider.is_in_group("player"):
			shoot_projectile()


func shoot_projectile():

	if projectile_scene == null:
		return

	var projectile = projectile_scene.instantiate()

	get_parent().add_child(projectile)

	projectile.global_position = global_position

	var shoot_direction = (player.global_position - global_position).normalized()

	projectile.set_shoot_direction(shoot_direction)

	is_shooting = true
	timer.start()


func activate():
	if activated or waking_up:
		return

	waking_up = true
	animated_sprite_2d.play("wake_up")


func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "wake_up":
		waking_up = false
		activated = true
		animated_sprite_2d.play("walk")


func _on_timer_timeout():
	is_shooting = false
