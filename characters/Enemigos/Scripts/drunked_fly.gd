extends enemy_base


@onready var animated_sprite_2d = $AnimatedSprite2D

@onready var floor_detection: RayCast2D = $AnimatedSprite2D/FloorDetection
@onready var crouch_ray: RayCast2D = $AnimatedSprite2D/Crouch_ray
@onready var left_ray: RayCast2D = $LeftRay
@onready var right_ray: RayCast2D = $RightRay

var directions=Vector2(1,1)
var fliping=false
var boing=[false,false]
var animations={ "idle":"Default", "move":"Default", "jump":"Default","fall":"Default"}

func _physics_process(delta):

	if (floor_detection.is_colliding() or crouch_ray.is_colliding()) and not boing[0]:
		directions.y*=-1
		boing[0]=true
	else:
		boing[0]=false
		
	if (left_ray.is_colliding() or right_ray.is_colliding()) and not boing[1]:
		directions.x*=-1
		boing[1]=true
	else:
		boing[1]=false
		
	if state_machine.current_state==$State_Machine/Idle:
		state_machine.change_to("Fly")
		 
	
	move_and_slide()


func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
