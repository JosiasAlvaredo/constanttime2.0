extends body_part
@onready var right_arm_position: Node2D = $right_arm_position
@onready var left_arm_position: Node2D = $left_arm_position
@onready var legs_position: Node2D = $legs_position

@export var shockwave=0

var total_weight=size
var body
var count_parts=0

var parent

func _ready() -> void:
	parent=get_parent().get_parent()
	body=GlobalValues.bodies_parts
	if body.right_arm!=null:
		var right_arm=load("res://characters/player/Body_parts/arms/%s.tscn" % body.right_arm._name).instantiate()
		right_arm.position=right_arm_position.position
		right_arm.z_index=1
		
		count_parts+=1
		total_weight+=right_arm.size
		
		add_child(right_arm)

	if body.left_arm!=null:
		var left_arm=load("res://characters/player/Body_parts/arms/%s.tscn" % body.left_arm._name).instantiate()
		left_arm.position=left_arm_position.position
		
		count_parts+=1
		total_weight+=left_arm.size
		
		add_child(left_arm)
		
	if body.legs!=null:
		var legs=load("res://characters/player/Body_parts/legs/%s.tscn" % body.legs._name).instantiate()
		legs.position=legs_position.position
		
		speed+=legs.speed
		jump_force+=legs.jump_force
		
		count_parts+=2
		total_weight-=legs.size*3
		
		add_child(legs)
		parent.body_botton=legs.foot_position.position.y*1.5
	else:
		parent.body_botton=10
	
	speed-=total_weight*25
	jump_force+=total_weight*30
	
	if speed<0:
		speed=0
	if jump_force>0:
		jump_force=0
	
	shockwave=shockwave/100
	
	parent.body_up=$Body_up
	parent.body_down=$Body_Down
	parent.Interactive_Box_collition=$Interactive_Box/CollisionShape2D

func torso_damage(_damage):
	#desgaste del torso
	var part_wear=shockwave*_damage
	durability-=part_wear
	
	#daño dirigido a las partes del cuerpo
	if body.right_arm!=null:
		body.right_arm.damage((_damage-part_wear)/count_parts)
	if body.left_arm!=null:
		body.left_arm.damage((_damage-part_wear)/count_parts)
	if body.legs!=null:
		body.legs.damage((_damage-part_wear)/int(count_parts/2))
