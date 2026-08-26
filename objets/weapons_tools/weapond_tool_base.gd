extends Node2D
class_name  weapond_item_base_class

@export var _name="Stick"
@export var item_texture:Sprite2D
@export var durability=1
var slot_position=null

var player

var skills=null

func _ready() -> void:
	player=get_parent().get_parent().get_parent().get_parent()

	skills=load("res://objets/items/skills/%s.tres" % _name)

func worn_out():
	slot_position.damage(1)
