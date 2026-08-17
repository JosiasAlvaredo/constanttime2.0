extends Node2D
@onready var right_arm_position: Node2D = $right_arm_position
@onready var left_arm_position: Node2D = $left_arm_position
@onready var legs_position: Node2D = $legs_position



var total_weight
var body
var count_parts=0

var parent
var skills

var _name=""

var current_habilities_names=[]

var abilities_idle_conections=[]
var abilities_move_conections=[]
var abilities_jump_conections=[]
var abilities_fall_conections=[]

var can_take_right_hand=false
var can_take_left_hand=false

func _ready() -> void:
	parent=get_parent().get_parent()
	for hability in parent.habilities_states.get_children():
		hability.free()
	
	body=GlobalValues.bodies_parts
	
	if body.torso !=null:
		_name=body.torso._name
	else:
		_name="none"
		
	skills=load("res://objets/body_parts/skills/%s.tres" % _name).duplicate()
	total_weight=skills.size

	#se crean las extremidades, se definen los stats y habilidades
	if body.right_arm!=null:
		var right_arm=load("res://characters/player/Body_parts/arms/%s.tscn" % body.right_arm._name).instantiate()
		var right_armSkills=load("res://objets/body_parts/skills/%s.tres" %  body.right_arm._name)

		right_arm.position=right_arm_position.position
		right_arm.z_index=1
		
		count_parts+=1
		total_weight+=right_armSkills.size
		
		can_take_right_hand=right_armSkills.can_take
		
		load_abilities(right_armSkills.number_habilities)
		
		add_child(right_arm)
	
	if body.left_arm!=null:
		var left_arm=load("res://characters/player/Body_parts/arms/%s.tscn" % body.left_arm._name).instantiate()
		var left_armSkills=load("res://objets/body_parts/skills/%s.tres" %  body.left_arm._name)

		left_arm.position=left_arm_position.position
		
		count_parts+=1
		total_weight+=left_armSkills.size
		can_take_left_hand=left_armSkills.can_take
		
		load_abilities(left_armSkills.number_habilities)
		
		add_child(left_arm)
	
	if body.legs!=null:
		var legs=load("res://characters/player/Body_parts/legs/%s.tscn" % body.legs._name).instantiate()
		var legsSkills=load("res://objets/body_parts/skills/%s.tres" %  body.legs._name)
		legs.position=legs_position.position
		
		
		skills.speed+=legsSkills.speed
		skills.jump_force+=legsSkills.jump_force
		
		count_parts+=2
		total_weight-=legsSkills.size*3
		
		load_abilities(legsSkills.number_habilities)

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


#Carga los nodos de estado en el nodo abilities del state machine
func load_abilities(number_habilities):
		for number_hability in number_habilities:
			var hability=skills.Habilities.keys()[number_hability]
			var hability_node=load("res://characters/States/player/habilities/%s.tscn" % hability)
			if hability_node!=null:
				hability_node=hability_node.instantiate()
				if not hability_node.name in current_habilities_names:
					current_habilities_names.append(hability_node.name)
					
					if hability_node.has_method("conect_Idle"):
						abilities_idle_conections.append(hability_node.conect_Idle)
						
					if hability_node.has_method("conect_move"):
						abilities_move_conections.append(hability_node.conect_move)
						
					if hability_node.has_method("conect_fall"):
						abilities_jump_conections.append(hability_node.conect_fall)
						
					if hability_node.has_method("conect_jump"):
						abilities_fall_conections.append(hability_node.conect_jump)

					parent.habilities_states.add_child(hability_node)

#Guardan las conecciones de las habilidades con su respectivo estado
func conect_Idle(controlled_node,state_machine):
	for conection in abilities_idle_conections:
		conection.call(controlled_node,state_machine) 
	
func conect_move(controlled_node,state_machine):
	for conection in abilities_move_conections:
		conection.call(controlled_node,state_machine) 
	
func conect_jump(controlled_node,state_machine):
	for conection in abilities_jump_conections:
		conection.call(controlled_node,state_machine) 
	
func conect_fall(controlled_node,state_machine):
	for conection in abilities_fall_conections:
		conection.call(controlled_node,state_machine) 
#_____________________________
