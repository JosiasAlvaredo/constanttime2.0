extends Node
class_name Item_base

@export var _name="Rock"
@export var durability=1

@export_enum("Bullet", "Mele") var kind: String
func use(player):
	durability-=1
	if player.hand_using=="Left":
		player.left_hand_sprite.get_child(0).text=str(durability)
	if player.hand_using=="Right":
		player.rigth_hand_sprite.get_child(0).text=str(durability)
	if durability<=0:
		if player.hand_using=="Left":
			player.left_hand_sprite.texture=null
			player.left_hand_sprite.get_child(0).text=""
		if player.hand_using=="Right":
			player.rigth_hand_sprite.texture=null
			player.rigth_hand_sprite.get_child(0).text=""
		return null
	else:
		return self

func _on_area_2d_area_entered(area: Area2D) -> void:
	var item_scene = load("res://objets/items/%s.tscn" % _name)
	var item = item_scene.instantiate()
	var player=area.get_parent().get_parent()
	
	if player.hand_using=="Left":
		GlobalValues.Left_hand=item
		player.left_hand_sprite.texture=item.get_child(0).texture
		player.left_hand_sprite.get_child(0).text=str(durability)
		self.queue_free()
		
	if player.hand_using=="Right":
		GlobalValues.Right_hand=item
		player.rigth_hand_sprite.texture=item.get_child(0).texture
		player.rigth_hand_sprite.get_child(0).text=str(durability)
		self.queue_free()
