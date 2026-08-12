extends Node2D
class_name Item_base

enum BodyParts { torso,left_arm,right_arm,legs,right_hand,left_hand }

@export var _name="Rock"
@export var durability=5
@export var number_kinds: Array[BodyParts] = [BodyParts.right_hand, BodyParts.left_hand]
@export var kind=[]
var item_sprite

var item 
var item_scene

func _ready() -> void:
	item_sprite=get_child(0)
	kind=[]
	for nro in number_kinds:
		kind.append(BodyParts.keys()[nro])

	if "Item" in kind:
		item_scene = load("res://objets/weapons_tools/%s.tscn" % _name)
		
func _on_area_2d_area_entered(area: Area2D) -> void:
	if "Item" in kind and false:
		var player=area.owner.owner
		
		item = item_scene.instantiate()
		
		player.body.add_child(item)
		
		if player.hand_using=="Left":
			GlobalValues.Left_hand={"name":_name,"durability":durability}
			player.left_hand_sprite.texture=load("res://assets/items/Weapons/%s.png" % _name)
			player.left_hand_sprite.get_child(0).text=str(durability)
			player.left_hand_item=item
			self.queue_free()
			
			
		if player.hand_using=="Right":
			GlobalValues.Right_hand={"name":_name,"durability":durability}
			player.right_hand_sprite.texture=load("res://assets/items/Weapons/%s.png" % _name)
			player.right_hand_sprite.get_child(0).text=str(durability)
			player.right_hand_item=item
			self.queue_free()
		

	
