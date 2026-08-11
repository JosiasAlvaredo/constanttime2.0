extends Node2D
@onready var right_arm_position: Node2D = $right_arm_position
@onready var left_arm_position: Node2D = $left_arm_position
@onready var legs_position: Node2D = $legs_position

#es el porcentaje de daño q se lleva el torso


var total_weight
var body
var count_parts=0

var parent
var skills

var _name=""

func _ready() -> void:
	body=GlobalValues.bodies_parts
	
	if body.torso !=null:
		_name=body.torso._name
	else:
		_name="none"
		
	skills=load("res://objets/body_parts/skills/%s.tres" % _name).duplicate()
	total_weight=skills.size
	parent=get_parent().get_parent()
	
	
	#se crean las extremidades y se definen los stats
	if body.right_arm!=null:
		var right_arm=load("res://characters/player/Body_parts/arms/%s.tscn" % body.right_arm._name).instantiate()
		var right_armSkills=load("res://objets/body_parts/skills/%s.tres" %  body.right_arm._name)

		right_arm.position=right_arm_position.position
		right_arm.z_index=1
		
		count_parts+=1
		total_weight+=right_armSkills.size
		
		add_child(right_arm)

	if body.left_arm!=null:
		var left_arm=load("res://characters/player/Body_parts/arms/%s.tscn" % body.left_arm._name).instantiate()
		var left_armSkills=load("res://objets/body_parts/skills/%s.tres" %  body.left_arm._name)

		left_arm.position=left_arm_position.position
		
		count_parts+=1
		total_weight+=left_armSkills.size
		
		add_child(left_arm)
		
	if body.legs!=null:
		var legs=load("res://characters/player/Body_parts/legs/%s.tscn" % body.legs._name).instantiate()
		var legsSkills=load("res://objets/body_parts/skills/%s.tres" %  body.legs._name)
		legs.position=legs_position.position
		
		
		skills.speed+=legsSkills.speed
		skills.jump_force+=legsSkills.jump_force
		
		count_parts+=2
		total_weight-=legsSkills.size*3
		
		add_child(legs)
		parent.body_botton=legs.foot_position.position.y*(1.5)+legs.position.y
	else:
		parent.body_botton=legs_position.position.y*1.5
		if parent.body_botton<10:
			parent.body_botton=10
	skills.speed-=total_weight*25
	skills.jump_force+=total_weight*30
	
	if skills.speed<0:
		skills.speed=0
	if skills.jump_force>0:
		skills.jump_force=0

	var shockwave=float(skills.shockwave)/100.0
	
	parent.body_up=$Body_up
	parent.body_down=$Body_Down
	parent.Interactive_Box_collition=$Interactive_Box/CollisionShape2D

func torso_damage(_damage):
	#desgaste del torso
	var part_wear=skills.shockwave*_damage
	#daño dirigido a las partes del cuerpo
	
	if body.torso!=null:
		body.torso.damage(part_wear)
	if body.right_arm!=null:
		body.right_arm.damage((_damage-part_wear)/count_parts)
	if body.left_arm!=null:
		body.left_arm.damage((_damage-part_wear)/count_parts)
	if body.legs!=null:
		body.legs.damage((_damage-part_wear)/int(count_parts/2))
