extends Node2D
class_name  weapond_item_base_class

@export var _name="Stick"
@export var damage=1
@export var durability=1
@export var recoil=100
@export var knockback=Vector2(-100,-100)
@export var item_texture:Sprite2D

var player

func _ready() -> void:
	player=get_parent().get_parent()
	

func worn_out():
	durability-=1
	if player.hand_using=="Left":
		player.left_hand_sprite.get_child(0).text=str(durability)
	if player.hand_using=="Right":
		player.right_hand_sprite.get_child(0).text=str(durability)
	if durability<=0:
		if player.hand_using=="Left":
			player.left_hand_sprite.texture=null
			player.left_hand_sprite.get_child(0).text=""
			GlobalValues.Left_hand={"name":"","durability":0}
			player.left_hand_item.queue_free()
			
		if player.hand_using=="Right":
			player.right_hand_sprite.texture=null
			player.right_hand_sprite.get_child(0).text=""
			GlobalValues.Right_hand={"name":"","durability":0}
			player.right_hand_item.queue_free()
	else:
		if player.hand_using=="Left":
			player.left_hand_sprite.get_child(0).text=str(durability)
			GlobalValues.Left_hand.durability=durability
		if player.hand_using=="Right":
			player.right_hand_sprite.get_child(0).text=str(durability)
			GlobalValues.Right_hand.durability=durability
