extends Node2D
class_name Item_base

@export var _name="Rock"
@export_enum("body_parts","items") var origin:String
@export var skills=null

var item_sprite

func _ready() -> void:
	item_sprite=get_child(0)
	await get_tree().create_timer(0.1).timeout
	if skills==null:
		skills=load("res://objets/%s/skills/%s.tres" %  [origin,_name]).duplicate()

	

	for nro in skills.number_kinds:
		skills.kind.append(GlobalValues.BodyParts.keys()[nro])
	
func _physics_process(delta: float) -> void:
	if skills!=null:
		if skills.durability<=0:
			queue_free()

	
