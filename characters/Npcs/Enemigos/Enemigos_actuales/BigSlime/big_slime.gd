extends enemy_base


@onready var ray_cast: Node2D = $RayCast
@onready var floor_ray: RayCast2D = $RayCast/FloorRay
@onready var front_ray: RayCast2D = $RayCast/FrontRay
@onready var sprite: Sprite2D = $Sprite2D


func _ready():
	direction = 1
	update_direction()


func change_direction():
	direction *= -1
	update_direction()


func update_direction():
	# Girar los RayCast
	ray_cast.scale.x = direction

	# Girar el sprite
	sprite.flip_h = direction < 0
