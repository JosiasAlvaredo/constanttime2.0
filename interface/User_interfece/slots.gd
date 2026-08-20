extends Button

@onready var user_interface: CanvasLayer = $"../../../.."
@onready var durability_node: Label = $Durability

@export_enum("torso","left_arm","right_arm","legs","right_hand","left_hand" ) var slot_part: String

var kind
var path=["res://objets/body_parts/%s.tscn", name]

var save_position=Vector2.ZERO
var can_drop=false

var mouse_on_this_slot=false

var taking_thing=false
var item_aux=null

var moving_thing=false

func _ready() -> void:
	save_position=position
	await  get_tree().create_timer(0.1).timeout

func _physics_process(delta: float) -> void:
	#crear un item aux para que el jugador pueda ver que objeto esta moviendo
	if user_interface.selected_body_part==item_aux and item_aux !=null:
		if not taking_thing:
			await get_tree().create_timer(0.2).timeout
			taking_thing=true
			get_parent().add_child(item_aux)
			
	#lo que se muestra en el slot (el objeto que esta ahi o nada)
	if GlobalValues.bodies_parts[slot_part]!=null and (item_aux==null or not moving_thing) :
		icon=GlobalValues.bodies_parts[slot_part].get_child(0).icon
		durability_node.text=str(int(GlobalValues.bodies_parts[slot_part].durability))
	elif moving_thing or GlobalValues.bodies_parts[slot_part]==null:
		icon=null
		durability_node.text=""

	#agregar algo en el slot o itercambiarlo con otra cosa
	if Input.is_action_just_pressed("Left_hand") and user_interface.selected_body_part!=null and mouse_on_this_slot and ((can_drop and item_aux!=null) or item_aux==null):
		if slot_part in user_interface.selected_body_part.kind:
			if GlobalValues.bodies_parts[slot_part]!=null:
				taking_thing=false
				item_aux=GlobalValues.bodies_parts[slot_part].duplicate()
				timer()
			GlobalValues.bodies_parts[slot_part]=user_interface.selected_body_part.duplicate()

			GlobalValues.bodies_parts[slot_part]._name=user_interface.selected_body_part._name
			
			user_interface.selected_body_part.delete()
			if item_aux==null:
				user_interface.selected_body_part=null
				icon=GlobalValues.bodies_parts[slot_part].get_child(0).icon
			else:
				user_interface.selected_body_part=item_aux

	#solar algo equipado o devolverlo a su lugar
	if Input.is_action_just_pressed("Left_hand") and can_drop and item_aux!=null:
		if not user_interface.mouse_on_a_slot:
			drop()
			
	#solar algo equipado o devolverlo a su lugar, por cerrar el inventario
	if Input.is_action_just_pressed("Inventory") and  GlobalValues.bodies_parts[slot_part]!=null and item_aux!=null:
		if not moving_thing:
			drop()
		else:
			reset_item_aux()

func timer():
	can_drop=false
	await get_tree().create_timer(0.5).timeout
	can_drop=true
	
#agarrar el item del slot	
func _on_button_down() -> void:
	if user_interface.selected_body_part==null and GlobalValues.bodies_parts[slot_part]!=null and item_aux==null and user_interface.inventory.visible:
		item_aux=GlobalValues.bodies_parts[slot_part].duplicate()
		GlobalValues.bodies_parts[slot_part]=null
		user_interface.selected_body_part=item_aux
		moving_thing=true
		taking_thing=false
		timer()

func drop():
	var drop=load("res://objets/body_parts/%s.tscn" % item_aux._name)
	
	if drop==null:
		drop=load("res://objets/items/%s.tscn" % item_aux._name)
	if drop==null:
		return
		
	drop=drop.instantiate()

	drop.durability=item_aux.durability
	
			
	user_interface.get_parent().add_child(drop)

	drop.kind=slot_part
	drop.global_position=user_interface.player.global_position
	if moving_thing:
		GlobalValues.bodies_parts[slot_part]=null
	user_interface.selected_body_part=null
	position=save_position
	mouse_on_this_slot=false
	user_interface.mouse_on_a_slot=false
	reset_item_aux()
	
func reset_item_aux():
	item_aux.queue_free()
	moving_thing=false
	user_interface.selected_body_part=null
	can_drop=false
	taking_thing=false

func _on_mouse_exited() -> void:
	user_interface.timer_clouse_info()
	user_interface.mouse_on_a_slot=false
	mouse_on_this_slot=false

func _on_mouse_entered() -> void:
	if GlobalValues.bodies_parts[slot_part]!=null:
		user_interface.analisis(GlobalValues.bodies_parts[slot_part])
	mouse_on_this_slot=true
	user_interface.mouse_on_a_slot=true

func turn(_bool):
	get_parent().visible=_bool
	
	if not _bool and GlobalValues.bodies_parts[slot_part]:
		item_aux=GlobalValues.bodies_parts[slot_part].duplicate()
		var drop=load("res://objets/body_parts/%s.tscn" % item_aux._name)
		
		if drop==null:
			drop=load("res://objets/items/%s.tscn" % item_aux._name)
		if drop==null:
			return
			
		drop=drop.instantiate()

		drop.durability=item_aux.durability
		
				
		user_interface.get_parent().add_child(drop)

		drop.kind=slot_part
		drop.global_position=user_interface.player.global_position
		item_aux.queue_free()
		GlobalValues.bodies_parts[slot_part]=null
