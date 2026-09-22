extends Node2D
class_name  weapond_item_base_class

@export var _name="Stick"
@export_enum("body_parts","items") var origin:String
@export var item_texture:Sprite2D
@export var durability=1
var slot_position=null

var player

var skills=null

func _ready() -> void:
	player=get_parent().get_parent().get_parent()
	if not player is Player:
		player=get_parent().get_parent().get_parent().get_parent()
	

	skills=load("res://objets/%s/skills/%s.tres" %  [origin,_name]).duplicate()

func worn_out():
	slot_position.skills.suffer_damage(1)
