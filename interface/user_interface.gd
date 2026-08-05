extends CanvasLayer

@onready var inventory: ColorRect = $inventory
@onready var near_objets_node: Node = $inventory/near_objets

var near_objets=[]
var save_near_objets=[]

var using_mouse=false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Inventory") and not inventory.visible:
		inventory.visible=true
	elif Input.is_action_just_pressed("Inventory"):
		inventory.visible=false
	
	if inventory.visible and save_near_objets!=near_objets:
		
		for slot_item in near_objets_node.get_children():
			slot_item.queue_free()
			
		for near_objet in near_objets:
			var new_slot_item=load("res://objets/slot_items/slot_item.tscn").instantiate()
			
			near_objets_node.add_child(new_slot_item)
			new_slot_item.item_sprite.texture=near_objet.item_sprite.texture
			new_slot_item.durability.text=str(near_objet.durability)
		save_near_objets=near_objets
