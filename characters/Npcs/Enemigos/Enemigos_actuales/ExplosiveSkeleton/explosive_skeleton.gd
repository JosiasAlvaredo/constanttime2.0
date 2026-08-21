extends CharacterBody2D


@export var dash_speed := 500.0
@export var dash_time := 0.15
@export var friction := 1200.0
@export var idle_time := 0.4
@export var gravity := 1000.0

var direction := 1

@onready var ray_cast: Node2D = $RayCast
@onready var floor_ray: RayCast2D = $RayCast/FloorRay
@onready var front_ray: RayCast2D = $RayCast/FrontRay
@onready var sprite: Sprite2D = $Sprite2D

@onready var state_machine: State_Machine = $State_Machine


func _physics_process(delta):
	# Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()


func change_direction():
	direction *= -1
	update_direction()

func update_direction():
	# Girar los RayCast
	ray_cast.scale.x = direction

	# Girar el sprite
	sprite.flip_h = direction < 0
