extends enemy_base


@export var projectile_scene: PackedScene


var playerUbi := Vector2.ZERO

@onready var ceiling_ray: RayCast2D = $RayCasts/CeilingRay
@onready var wall_ray: RayCast2D = $RayCasts/WallRay
@onready var player_ray: RayCast2D = $RayCasts/PlayerRay
@onready var shoot_point: Marker2D = $ShootPoint


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node2D


func _physics_process(delta: float) -> void:

	# Actualizar continuamente el PlayerRay
	update_player_ray()


func update_player_ray() -> void:

	if player == null:
		return

	# Apuntar el RayCast hacia la posición actual del jugador
	player_ray.target_position = (
		player.global_position - player_ray.global_position
	)

	# Actualizar inmediatamente la colisión
	player_ray.force_raycast_update()


func can_see_player() -> bool:

	if player == null:
		return false

	if not player_ray.is_colliding():
		return false

	# Objeto que está bloqueando el RayCast
	var collider = player_ray.get_collider()

	# Solo devuelve true si lo primero que golpea es el jugador
	return collider == player
func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
