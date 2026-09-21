
extends enemy_base

@export var jump_force: float = 250.0

@onready var ray_cast: Node2D = $RayCast
@onready var floor_ray: RayCast2D = $RayCast/FloorRay
@onready var front_ray: RayCast2D = $RayCast/FrontRay
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	direction = 1
	update_direction()


func change_direction() -> void:
	direction *= -1
	update_direction()


func update_direction() -> void:
	# Girar los RayCast
	ray_cast.scale.x = abs(ray_cast.scale.x) * direction

	# Girar el Sprite según la dirección
	if direction == 1:
		sprite.flip_h = true
	else:
		sprite.flip_h = false


func _physics_process(delta: float) -> void:
	pass


func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
