extends enemy_base


@export var projectile_scene: PackedScene
@export var shoot_cooldown := 1.5


var player_objetivo: Node2D


@onready var raycasts: Node2D = $RayCasts
@onready var floor_ray: RayCast2D = $RayCasts/FloorRay
@onready var front_ray: RayCast2D = $RayCasts/FrontRay
@onready var shoot_point: Marker2D = $RayCasts/ShootPoint
@onready var player_ray: RayCast2D = $PlayerRay
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	player_objetivo = get_tree().get_first_node_in_group("player")
	sprite.scale.x=direction*abs(sprite.scale.x)
	update_direction()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()


# ==========================================
# CAMBIAR DIRECCIÓN
# ==========================================

func change_direction() -> void:
	direction *= -1
	update_direction()


# ==========================================
# GIRAR LO QUE CORRESPONDE
# ==========================================

func update_direction() -> void:

	# Invierte FloorRay, FrontRay y ShootPoint
	raycasts.scale.x = abs(raycasts.scale.x) * direction

	# Sprite
	if direction == 1:
		sprite.flip_h = true
	else:
		sprite.flip_h = false


# ==========================================
# VER AL JUGADOR
# ==========================================

func can_see_player() -> bool:
	if player_objetivo == null:
		return false

	var distance = global_position.distance_to(
		player_objetivo.global_position
	)

	if distance > 400:
		return false

	player_ray.target_position = (
		player_ray.to_local(player_objetivo.global_position)
	)

	player_ray.force_raycast_update()

	if not player_ray.is_colliding():
		return false

	return player_ray.get_collider() == player_objetivo


# ==========================================
# RECIBIR DAÑO
# ==========================================

func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
