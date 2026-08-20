extends Node2D
class_name Item_base

enum BodyParts { torso,left_arm,right_arm,legs,right_hand,left_hand }

@export var _name="Rock"
@export var durability=5
@export var number_kinds: Array[BodyParts] = [BodyParts.right_hand, BodyParts.left_hand]
@export var kind=[]
var item_sprite

func _ready() -> void:
	item_sprite=get_child(0)
	kind=[]
	for nro in number_kinds:
		kind.append(BodyParts.keys()[nro])

		
		

	
