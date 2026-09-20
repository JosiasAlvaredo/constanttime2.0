extends CanvasLayer


@onready var near_objets_node = $Inventory/inventory/near_objets/GridContainer
@onready var player: Player = $"../Player"

@onready var inventory: Node2D = $Inventory
@onready var info: Node2D = $Inventory/info
@onready var info_animations: AnimationPlayer = $Inventory/info/Info_animations

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
	#Iteraccion del inventatio con el exterior
	if inventory.visible and save_near_objets!=near_objets:
		for slot_item in near_objets_node.get_children():
			slot_item.queue_free()

		#mostrar cosas en el piso y ordenarlas
		for i in range(len(near_objets)):
			var near_objet=near_objets[i]
			var new_slot_item=load("res://interface/User_interfece/items_in_grid.tscn").instantiate()
			near_objets_node.add_child(new_slot_item)
			new_slot_item.icon=near_objet.item_sprite.texture
			new_slot_item.skills=near_objet.skills

			new_slot_item.link_to_original=near_objet
		save_near_objets=near_objets.duplicate()
	
	$hands/Node2D/AnimatedSprite2D/right_hand.turn(player.current_torso.can_take_right_hand)
	$hands/Node2D/AnimatedSprite2D2/left_hand.turn(player.current_torso.can_take_left_hand)
	
func rebuil_body():
	await get_tree().create_timer(0.1).timeout
	player.buil_body()
		
#muestra la info de objeto
func analisis(obj):
	var skills=obj.skills
	if skills!=null:
		var size_icons=[$Inventory/info/small_icon,$Inventory/info/medium_icon,$Inventory/info/big_icon]
		checking_info=true
		if info_animations.current_animation=="Info_unvisible":
			info_animations.play("Info_open")
		
		$Inventory/info/name.text=skills.spanish_name
		$Inventory/info/durability.text=str(skills.durability)
		
		if skills.damage!=0:
			$Inventory/info/strength.visible=true
			$Inventory/info/strength.text=str(skills.damage)
		else:
			$Inventory/info/strength.visible=false
		
		if "shockwave" in skills:
			if skills.shockwave!=0:
				$Inventory/info/shockwave.visible=true
				$Inventory/info/shockwave.text=str(skills.shockwave)
			else:
				$Inventory/info/shockwave.visible=false
		if "speed" in skills:	
			if skills.speed!=0:
				$Inventory/info/velocity.visible=true
				$Inventory/info/velocity.text=str(skills.speed)
			else:
				$Inventory/info/velocity.visible=false
				
		if "jump_force" in skills:
			if skills.jump_force!=0:
				$Inventory/info/jump.visible=true
				$Inventory/info/jump.text=str(abs(skills.jump_force))
			else:
				$Inventory/info/jump.visible=false
			
		$Inventory/info/Descripccion.text=skills.description
			
func timer_clouse_info():
	checking_info=false
	await get_tree().create_timer(0.5).timeout
	if not checking_info and info_animations.current_animation=="Info_visible":
		info_animations.play("Info_close")


func _on_menu_box_mouse_entered() -> void:
	player.mouse_on_menu=true



func _on_menu_box_mouse_exited() -> void:
	player.mouse_on_menu=false
