extends Node2D
class_name  weapond_item_base_class

@export var _name="Stick"
@export var damage=1
@export var durability=1
@export var recoil=100
@export var knockback=Vector2(-100,-100)
@export var item_texture:Sprite2D

var slot_position=null

var player

func _ready() -> void:
	player=get_parent().get_parent().get_parent()
	

func worn_out():
	slot_position.damage(1)
