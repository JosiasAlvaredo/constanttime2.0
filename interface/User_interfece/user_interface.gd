extends CanvasLayer


@onready var near_objets_node = $Inventory/inventory/near_objets
@onready var player: Player = $"../Player"

@onready var inventory: Node2D = $Inventory
@onready var info: Node2D = $Inventory/info
@onready var info_animations: AnimationPlayer = $Inventory/info/Info_animations

@onready var bodies_parts_slots_1: Node2D = $Inventory/inventory/Bodies_parts_slots
@onready var bodies_parts_slots_2: Node2D = $hands/Node2D/slots

var near_objets=[]
var save_near_objets=[]

var selected_body_part=null
var mouse_on_a_slot=false
var checking_info=false

func _physics_process(delta: float) -> void:
	#abrir inventario
	if Input.is_action_just_pressed("Inventory") and not inventory.visible:
		inventory.visible=true
	#cerrar inventario
	elif Input.is_action_just_pressed("Inventory"):
		inventory.visible=false
		info_animations.play("Info_unvisible")
	#Iteraccion del invetatio con el exterior
	if inventory.visible and save_near_objets!=near_objets:
		for slot_item in near_objets_node.get_children():
			slot_item.queue_free()
		var pos_y=0
		#mostrar cosas en el piso y ordenarlas
		for i in range(len(near_objets)):
			if i%5==4:
				pos_y+=50
			var near_objet=near_objets[i]
			var new_slot_item=load("res://interface/User_interfece/slot_items/slot_item.tscn").instantiate()
			near_objets_node.add_child(new_slot_item)
			new_slot_item.button.icon=near_objet.item_sprite.texture
			new_slot_item.durability=int(near_objet.durability)
			new_slot_item.kind=near_objet.kind
			new_slot_item.path="res://objets/body_parts/%s.tscn" % near_objet._name
			
			new_slot_item._name=near_objet._name
			new_slot_item.save_position=Vector2((i%5)*50,pos_y)
			new_slot_item.link_to_original=near_objet
		save_near_objets=near_objets.duplicate()
		
func rebuil_body():
	await get_tree().create_timer(0.1).timeout
	player.buil_body()
		
#muestra la info de objeto
func analisis(obj):
	var skills=load("res://objets/body_parts/skills/%s.tres" % obj._name)
	if skills!=null:
		var size_icons=[$Inventory/info/small_icon,$Inventory/info/medium_icon,$Inventory/info/big_icon]
		checking_info=true
		if info_animations.current_animation=="Info_unvisible":
			info_animations.play("Info_open")
		
		$Inventory/info/name.text=obj._name
		$Inventory/info/durability.text=str(obj.durability)
		
		if skills.damage!=0:
			$Inventory/info/strength.visible=true
			$Inventory/info/strength.text=str(skills.damage)
		else:
			$Inventory/info/strength.visible=false
			
		if skills.jump_force!=0:
			$Inventory/info/jump.visible=true
			$Inventory/info/jump.text=str(float(abs(skills.jump_force))/100)
		else:
			$Inventory/info/jump.visible=false
			
		if skills.speed!=0:
			$Inventory/info/velocity.visible=true
			$Inventory/info/velocity.text=str(float(skills.speed)/100)
		else:
			$Inventory/info/velocity.visible=false
		
		for size_icon in size_icons:
			if skills.size-1==size_icons.find(size_icon):
				size_icon.visible=true
			else:
				size_icon.visible=false
	
func timer_clouse_info():
	checking_info=false
	await get_tree().create_timer(0.5).timeout
	if not checking_info:
		info_animations.play("Info_close")
