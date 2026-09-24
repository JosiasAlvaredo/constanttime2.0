extends enemy_base


@onready var ray_cast: Node2D = $RayCast
@onready var floor_ray: RayCast2D = $RayCast/FloorRay
@onready var front_ray: RayCast2D = $RayCast/FrontRay
@onready var sprite = $AnimatedSprite2D

var start_flip

func _ready():
	start_flip=!sprite.flip_h

	direction = 1
	update_direction()
	sprite.scale.x=direction*abs(sprite.scale.x)

func change_direction():
	direction *= -1
	update_direction()


func update_direction():
	# Girar los RayCast
	ray_cast.scale.x = direction

	# Girar el sprite
	sprite.flip_h = direction < 0 == start_flip

func _physics_process(delta: float) -> void:
	if velocity.x!=0 and is_on_floor():
		velocity.y=Jump_stength
		
func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
