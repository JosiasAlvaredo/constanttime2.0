extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
const MAX_SPEED: float = 100.0

func _ready():
	$AnimatedSprite2D.scale.x *= 1
	velocity.x = MAX_SPEED

func _next_to_left_wall() -> bool:
	return $LeftRay.is_colliding()

func _next_to_right_wall() -> bool:
	return $RightRay.is_colliding()

func _floor_detection() -> bool:
	return $AnimatedSprite2D/FloorDetection.is_colliding()

func _flip():
	if _next_to_right_wall() or _next_to_left_wall() or !_floor_detection():
		velocity.x *= -1
		$AnimatedSprite2D.scale.x *= -1

func _physics_process(delta):
	if GlobalValues.is_dialogue_active:
		return
	
	animated_sprite.play("default")
	velocity.y += GlobalValues.gravity
	_flip()
	move_and_slide()
