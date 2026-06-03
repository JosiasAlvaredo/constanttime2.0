extends Stats
class_name Player

@onready var body_up: RayCast2D = $AnimatedSprite2D/Body_up
@onready var body_down: RayCast2D = $AnimatedSprite2D/Body_Down

@onready var stand_up_collition: CollisionShape2D = $Stand_up_collition
@onready var crouched_collition: CollisionShape2D = $Crouched_collition

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var bullet: RayCast2D = $Bullet
@onready var mele_collision: CollisionShape2D = $AnimatedSprite2D/Mele/CollisionShape2D

@export var Left_hand:Item_base=null
@export var Right_hand:Item_base=null

@onready var hit_box: Area2D = $Hit_box

@onready var Interactive_Box_collition: CollisionShape2D = $AnimatedSprite2D/Interactive_Box/CollisionShape2D

var hand_using=""

var gravity:float= ProjectSettings.get_setting("physics/2d/default_gravity")

var direction=1
var direction_y=0

func _physics_process(delta: float) -> void:
	direction=-Input.get_axis("Right","Left")
	direction_y=-Input.get_axis("Up","Crouch")
	velocity.y+= gravity*delta
	
	bullet.target_position=get_local_mouse_position()
	
	move_and_slide()


	
