extends CanvasLayer

@onready var inventory: ColorRect = $inventory
@onready var near_objets_node = $inventory/near_objets
@onready var player: Player = $"../Player"

var near_objets=[]
var save_near_objets=[]

var selected_body_part=null
var mouse_on_a_slot=false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Inventory") and not inventory.visible:
		inventory.visible=true
	elif Input.is_action_just_pressed("Inventory"):
		inventory.visible=false
	
	if inventory.visible and save_near_objets!=near_objets:
		for slot_item in near_objets_node.get_children():
			slot_item.queue_free()
		var pos_y=0
		for i in range(len(near_objets)):
			if i%5==4:
				pos_y+=50
			var near_objet=near_objets[i]
			var new_slot_item=load("res://objets/slot_items/slot_item.tscn").instantiate()
			near_objets_node.add_child(new_slot_item)
			new_slot_item.button.icon=near_objet.item_sprite.texture
			new_slot_item.durability=int(near_objet.durability)
			new_slot_item.kind=near_objet.kind
			new_slot_item.path="res://objets/body_parts/%s.tscn" % near_objet._name
			
			new_slot_item._name=near_objet._name
			new_slot_item.save_position=Vector2((i%5)*50,pos_y)
			new_slot_item.link_to_original=near_objet
		save_near_objets=near_objets.duplicate()
		
