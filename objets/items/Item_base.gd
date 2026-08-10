extends Node2D
class_name Item_base



@export var _name="Rock"
@export var durability=5
@export_enum("torso","left_arm","right_arm","legs","Item") var kind: String="Item"

var item_sprite

var item 
var item_scene

func _ready() -> void:
	item_sprite=get_child(0)
	if kind =="Item":
		item_scene = load("res://objets/weapons_tools/%s.tscn" % _name)
		
func _on_area_2d_area_entered(area: Area2D) -> void:
	if kind=="Item":
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
		

	
