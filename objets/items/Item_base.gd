extends Node2D
class_name Item_base

@export var _name="Rock"
@export var durability=5
@export var current_effects=[]
@export_enum("body_parts","items") var origin:String
@export var skills=null

var item_sprite

func _ready() -> void:
	item_sprite=get_child(0)
	await get_tree().create_timer(0.1).timeout
	if skills==null:
		skills=load("res://objets/%s/skills/%s.tres" %  [origin,_name]).duplicate()
	skills.durability=durability
	

	for nro in skills.number_kinds:
		skills.kind.append(GlobalValues.BodyParts.keys()[nro])
	
func suffer_damage(_damage):
	durability-=_damage
	if durability<=0:
		queue_free()

	
