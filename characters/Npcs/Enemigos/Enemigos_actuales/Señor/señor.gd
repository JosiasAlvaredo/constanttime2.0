extends CharacterBody2D

@export var speed := 60.0
@export var gravity := 1000.0

@onready var wall_ray: RayCast2D = $RayCasts/WallRay
@onready var floor_ray: RayCast2D = $RayCasts/FloorRay
@onready var player_ray: RayCast2D = $RayCasts/PlayerRay

@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var direction := 1


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func change_direction() -> void:
	direction *= -1

	# RayCast de pared
	wall_ray.target_position.x *= -1

	# RayCast del jugador
	player_ray.target_position.x *= -1

	# RayCast del piso
	floor_ray.position.x *= -1

	# Area de ataque
	attack_collision.position.x *= -1

	# Sprite
	$Sprite2D.flip_h = direction < 0
