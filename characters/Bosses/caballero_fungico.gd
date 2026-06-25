extends enemy_base

var distance=0
var animations={ "Basic":"Basic", "Petrified":"Petrified", "Transform":"Transform"}
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func FLIP():
	if sign(distance.x)!=0:
		direction = sign(distance.x)
		$AnimatedSprite2D.scale.x = direction

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
