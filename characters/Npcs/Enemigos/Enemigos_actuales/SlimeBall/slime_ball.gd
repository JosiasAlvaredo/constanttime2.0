extends enemy_base

@onready var down_ray: RayCast2D = $RayCast/downRay
@onready var rigth_ray: RayCast2D = $RayCast/rigthRay
@onready var up_ray: RayCast2D = $RayCast/upRay
@onready var left_ray: RayCast2D = $RayCast/leftRay

@onready var up_sprite: AnimatedSprite2D = $up_sprite
@onready var left_sprite: AnimatedSprite2D = $left_sprite
@onready var rigth_sprite: AnimatedSprite2D = $rigth_sprite
@onready var down_sprite: AnimatedSprite2D = $down_sprite

@export var vectorDirection=Vector2(1,1)


var downLock=false
var rigthLock=false
var upLock=false
var leftLock=false

func _physics_process(delta: float) -> void:
	
	if down_ray.is_colliding() and not downLock:
		vectorDirection.y=-1*randf_range(0.75,1)
		downLock=true
		speed*=2
		down_sprite.play("crush")
	elif downLock:
		speed/=2
		downLock=false
		
	if up_ray.is_colliding() and not upLock:
		vectorDirection.y=1*randf_range(0.75,1)
		upLock=true
		speed*=2
		up_sprite.play("crush")
	elif upLock:
		speed/=2
		upLock=false
		
	if left_ray.is_colliding() and not leftLock:
		vectorDirection.x=1*randf_range(0.75,1)
		leftLock=true
		speed*=2
		left_sprite.play("crush")
	elif leftLock:
		speed/=2
		leftLock=false
		
	if rigth_ray.is_colliding() and not rigthLock:
		vectorDirection.x=-1*randf_range(0.75,1)
		rigthLock=true
		speed*=2
		rigth_sprite.play("crush")
	elif rigthLock:
		speed/=2
		rigthLock=false
		
	move_and_slide()


func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
	speed*=2
	up_sprite.play("crush")
	left_sprite.play("crush")
	rigth_sprite.play("crush")
	down_sprite.play("crush")
