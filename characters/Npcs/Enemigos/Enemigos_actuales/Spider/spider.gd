extends enemy_base


@export var projectile_scene: PackedScene
@export var detection_range := 400.0


var playerUbi := Vector2.ZERO


@onready var raycasts: Node2D = $RayCasts
@onready var ceiling_ray: RayCast2D = $RayCasts/CeilingRay
@onready var wall_ray: RayCast2D = $RayCasts/WallRay
@onready var player_ray: RayCast2D = $PlayerRay
@onready var shoot_point: Marker2D = $RayCasts/ShootPoint
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node2D
	
	update_rays_direction()
	update_sprite_direction()


func _physics_process(delta: float) -> void:
	# Gravedad invertida: empuja hacia arriba
	velocity.y -= gravity * delta
	
	# Actualizar continuamente el raycast hacia el jugador
	update_player_ray()


# ==========================================
# DIRECCIÓN DE LOS RAYCAST
# ==========================================

func update_rays_direction() -> void:
	raycasts.scale.x = abs(raycasts.scale.x) * direction


# ==========================================
# DIRECCIÓN DEL SPRITE
# ==========================================

func update_sprite_direction() -> void:
	if direction == 1:
		sprite_2d.flip_h = true
	else:
		sprite_2d.flip_h = false


# ==========================================
# DISTANCIA AL JUGADOR
# ==========================================

func get_player_distance() -> float:
	if player == null:
		return INF
	
	return global_position.distance_to(player.global_position)


func is_player_in_range() -> bool:
	return get_player_distance() <= detection_range


# ==========================================
# RAYCAST HACIA EL JUGADOR
# ==========================================

func update_player_ray() -> void:
	if player == null:
		return
	
	player_ray.target_position = (
		player.global_position - player_ray.global_position
	)
	
	player_ray.force_raycast_update()


# ==========================================
# ¿PUEDE VER AL JUGADOR?
# ==========================================

func can_see_player() -> bool:
	if player == null:
		return false
	
	# Fuera del rango
	if not is_player_in_range():
		return false
	
	# El RayCast no toca nada
	if not player_ray.is_colliding():
		return false
	
	var collider = player_ray.get_collider()
	
	# Solo puede verlo si lo primero que toca es el jugador
	return collider == player


# ==========================================
# RECIBIR DAÑO
# ==========================================

func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
