extends enemy_base


@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var crouch_ray: RayCast2D = $AnimatedSprite2D/Crouch_ray
@onready var front_ray: RayCast2D = $AnimatedSprite2D/Front_ray
@onready var floor_detection: RayCast2D = $AnimatedSprite2D/FloorDetection

var fliping=false

var animations={ "idle":"Default", "move":"Default", "jump":"Default","fall":"Default"}



func FLIP():
	if (front_ray.is_colliding() or !floor_detection.is_colliding()) and not player:
		direction *= -1
		animated_sprite_2d.scale.x *= -1
	if player!=null:
		direction = sign(player.global_position-global_position)
		animated_sprite_2d.scale.x = abs(animated_sprite_2d.scale.x)*direction

func _physics_process(delta):
	velocity.y+= gravity*delta
	
	if state_machine.current_state==$State_Machine/Idle:
		direction=last_direction
		state_machine.change_to("Move")
		
	
	move_and_slide()


func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())


func _on_area_2d_body_entered(body: Node2D) -> void:
	player=body
	speed=400
	
