extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var move_distance := 200.0
@export var move_speed := 100.0

@onready var timer = $Timer
@onready var ray_cast_2d = $RayCast2D
@onready var sprite = $Sprite2D

var activated = false
var is_shooting = false
var player

var start_x : float
var direction := 1


func _ready():
	player = get_tree().get_first_node_in_group("player")
	start_x = global_position.x


func _physics_process(delta):
	if !activated:
		return

	# MOVIMIENTO IZQ / DER
	velocity.x = direction * move_speed

	if global_position.x >= start_x + move_distance:
		direction = -1
	elif global_position.x <= start_x - move_distance:
		direction = 1

	move_and_slide()

	# ✔ GIRAR SPRITE SEGÚN DIRECCIÓN
	if direction == 1:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

	# ✔ RAYCAST APUNTANDO AL JUGADOR (FIX IMPORTANTE)
	if player:
		ray_cast_2d.target_position = ray_cast_2d.to_local(player.global_position)

	# LÓGICA DE DISPARO
	if is_shooting:
		return

	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()
		if collider.is_in_group("player"):
			shoot_projectile()


func shoot_projectile():
	if projectile_scene == null:
		print("NO HAY ESCENA DE PROYECTIL ASIGNADA")
		return

	var projectile_instance = projectile_scene.instantiate()
	get_parent().add_child(projectile_instance)

	# posición segura global
	projectile_instance.global_position = global_position

	var collision_point = ray_cast_2d.get_collision_point()
	var shoot_direction = (collision_point - global_position).normalized()

	projectile_instance.set_shoot_direction(shoot_direction)

	is_shooting = true
	timer.start()


func activate():
	activated = true


func _on_timer_timeout():
	is_shooting = false
