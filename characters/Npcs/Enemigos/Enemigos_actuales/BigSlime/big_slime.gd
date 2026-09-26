extends enemy_base


@onready var ray_cast: Node2D = $RayCast
@onready var floor_ray: RayCast2D = $RayCast/FloorRay
@onready var front_ray: RayCast2D = $RayCast/FrontRay
@onready var sprite= $AnimatedSprite2D

var start_flip

func _ready():
	start_flip=true
	$AnimatedSprite2D.scale.x=direction*abs($AnimatedSprite2D.scale.x)
	update_direction()


func change_direction():
	direction *= -1
	update_direction()


func update_direction():
	# Girar los RayCast
	ray_cast.scale.x = direction

	# Girar el sprite
	sprite.flip_h = direction < 0


func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
