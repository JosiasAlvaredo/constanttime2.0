extends CharacterBody2D

@export var speed := 50.0
@export var gravity := 1000.0

@export var projectile_scene: PackedScene
@export var shoot_cooldown := 1.5

var direction := 1
var player: Node2D

@onready var floor_ray: RayCast2D = $RayCasts/FloorRay
@onready var front_ray: RayCast2D = $RayCasts/FrontRay
@onready var player_ray: RayCast2D = $RayCasts/PlayerRay
@onready var shoot_point: Marker2D = $Marker2D_ShootPoint


func _ready():
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()
	
func change_direction():
	direction *= -1

	front_ray.target_position.x *= -1
	floor_ray.position.x *= -1
	floor_ray.target_position.x *= -1
	
func can_see_player() -> bool:
	if player == null:
		return false

	var distance = global_position.distance_to(player.global_position)

	if distance > 400:
		return false

	player_ray.target_position = to_local(player.global_position)
	player_ray.force_raycast_update()

	if player_ray.is_colliding():
		return player_ray.get_collider() == player

	return false
	
func shoot():
	if projectile_scene == null:
		return

	var projectile = projectile_scene.instantiate()

	get_tree().current_scene.add_child(projectile)

	projectile.global_position = shoot_point.global_position

	var direction_to_player = (
		player.global_position - shoot_point.global_position
	).normalized()

	projectile.direction = direction_to_player
