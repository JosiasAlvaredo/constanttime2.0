extends enemy_base

@onready var eye_ray: RayCast2D = $eye_ray

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var crouch_ray: RayCast2D = $AnimatedSprite2D/Crouch_ray
@onready var create_bomb: Node2D = $create_bomb

@export var shoot_velocity=10

var player

var fliping=false

var animations={ "idle":"Default", "move":"Default", "jump":"Default","fall":"Default"}

func _next_to_left_wall() -> bool:
	return $LeftRay.is_colliding()

func _next_to_right_wall() -> bool:
	return $RightRay.is_colliding()

func _floor_detection() -> bool:
	return $AnimatedSprite2D/FloorDetection.is_colliding()

func FLIP():
	if _next_to_right_wall() or _next_to_left_wall() or !_floor_detection():
		direction *= -1
		$AnimatedSprite2D.scale.x *= -1

func Flip_to(target):
	var distance=target.global_position.x-global_position.x
	if sign(distance)!=0:
		direction = sign(distance)
		$AnimatedSprite2D.scale.x = direction

func _physics_process(delta):
	velocity.y+= gravity*delta

	if state_machine.current_state==$State_Machine/Idle:
		direction=last_direction
		state_machine.change_to("Move")
		
	
	move_and_slide()


func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())


func _on_watch_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		state_machine.change_to("Shoot_gravity_objets")
		velocity=Vector2.ZERO



func _on_watch_area_body_exited(body: Node2D) -> void:
	state_machine.change_to("Move")
