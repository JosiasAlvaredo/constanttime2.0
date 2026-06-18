extends Node
class_name Item_base

@export var _name="Rock"

@export_enum("Bullet", "Mele") var kind: String

var item 
var item_scene

func _ready() -> void:
	item_scene = load("res://objets/weapons_tools/%s.tscn" % _name)
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	var player=area.owner
	
	item = item_scene.instantiate()
	
	player.animated_sprite_2d.add_child(item)
	
	if player.hand_using=="Left":
		GlobalValues.Left_hand={"name":_name,"durability":item.durability}
		player.left_hand_sprite.texture=item.item_texture
		player.left_hand_sprite.get_child(0).text=str(item.durability)
		player.left_hand_item=item
		self.queue_free()
		
		
	if player.hand_using=="Right":
		GlobalValues.Right_hand={"name":_name,"durability":item.durability}
		player.right_hand_sprite.texture=item.item_texture
		player.right_hand_sprite.get_child(0).text=str(item.durability)
		player.right_hand_item=item
		self.queue_free()
