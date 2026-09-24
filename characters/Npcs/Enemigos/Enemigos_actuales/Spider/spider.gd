extends enemy_base


@export var projectile_scene: PackedScene
@export var detection_range := 400.0

var playerUbi := Vector2.ZERO

# Movimiento inicial hasta llegar al techo
var llegando_al_techo := true

@onready var raycasts: Node2D = $RayCasts
@onready var ceiling_ray: RayCast2D = $RayCasts/CeilingRay
@onready var wall_ray: RayCast2D = $RayCasts/WallRay
@onready var player_ray: RayCast2D = $PlayerRay
@onready var shoot_point: Marker2D = $RayCasts/ShootPoint
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node2D
	sprite_2d.scale.x=direction*abs(sprite_2d.scale.x)
	update_rays_direction()
	update_sprite_direction()


func _physics_process(delta: float) -> void:

	# Actualizar el raycast hacia el jugador
	update_player_ray()


	# ==========================================
	# SUBIR AL TECHO AL INICIAR
	# ==========================================

	if llegando_al_techo:

		velocity.x = 0
		velocity.y = -speed

		move_and_slide()

		# La colisión física determina cuándo
		# llegó al techo.
		if is_on_ceiling():
			velocity = Vector2.ZERO
			llegando_al_techo = false

		return


	# ==========================================
	# YA ESTÁ EN EL TECHO
	# ==========================================

	# No usamos gravedad.
	# Patrol controla el movimiento horizontal.
	velocity.y = 0


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

	if not is_player_in_range():
		return false

	if not player_ray.is_colliding():
		return false

	var collider = player_ray.get_collider()

	return collider == player


# ==========================================
# RECIBIR DAÑO
# ==========================================

func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
