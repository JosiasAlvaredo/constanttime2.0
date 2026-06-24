extends CharacterBody2D
class_name Stats

@export var live=1

@export var aceleration=50
@export var Jump_stength=-300
@export var speed=300
@export var Climb_velocity=-150
@export var roll_velocity=600

@export var Knockback_resistence=0
@export var knockback=Vector2(-200,-100)

@export var damage=5

@export var activate_Gravity=true
@export var solid=true

var trapped=false

var can_roll=true
var can_jump=true

var gravity:float= ProjectSettings.get_setting("physics/2d/default_gravity")

func _enter_tree() -> void:
	Knockback_resistence=1-(Knockback_resistence/100)
	
func delay_roll():
	can_roll=false
	await get_tree().create_timer(0.4).timeout
	can_roll=true
	
func _process(delta: float) -> void:
		
	if solid:
		set_collision_mask_value(1,true)
	else:
		set_collision_mask_value(1,false)
