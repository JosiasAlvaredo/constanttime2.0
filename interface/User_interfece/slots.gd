extends Button

@onready var user_interface: CanvasLayer = $"../../.."
@onready var durability_node: Label = $Durability

@export_enum("torso","left_arm","right_arm","legs","right_hand","left_hand") var slot_part: String
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

	if user_interface.selected_body_part==item_aux and item_aux !=null:
		if not taking_thing:
			await get_tree().create_timer(0.2).timeout
			taking_thing=true
			get_parent().add_child(item_aux)

	if GlobalValues.bodies_parts[slot_part]!=null and (item_aux==null or not moving_thing) :
		icon=GlobalValues.bodies_parts[slot_part].get_child(0).icon
		durability_node.text=str(GlobalValues.bodies_parts[slot_part].durability)
	elif moving_thing or GlobalValues.bodies_parts[slot_part]==null:
		icon=null
		durability_node.text=""

	if Input.is_action_just_pressed("Left_hand") and user_interface.selected_body_part!=null and mouse_on_this_slot and ((can_drop and GlobalValues.bodies_parts[slot_part]!=null) or  GlobalValues.bodies_parts[slot_part]==null or (GlobalValues.bodies_parts[slot_part]!=null and item_aux==null)):
		if user_interface.selected_body_part.kind==slot_part:
			
			if GlobalValues.bodies_parts[slot_part]!=null and item_aux==null:
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

	if Input.is_action_just_pressed("Left_hand") and can_drop and  GlobalValues.bodies_parts[slot_part]!=null:
		if not user_interface.mouse_on_a_slot:
			drop()
		elif mouse_on_this_slot:
			reset_item_aux()
			
	if Input.is_action_just_pressed("Inventory") and  GlobalValues.bodies_parts[slot_part]!=null and item_aux!=null:
		if not moving_thing:
			drop()
		else:
			reset_item_aux()
			
func timer():
	can_drop=false
	await get_tree().create_timer(0.5).timeout
	can_drop=true
	
func _on_button_down() -> void:
	if user_interface.selected_body_part==null and GlobalValues.bodies_parts[slot_part] and item_aux==null:
		item_aux=GlobalValues.bodies_parts[slot_part].duplicate()
		user_interface.selected_body_part=item_aux
		moving_thing=true
		timer()

func drop():
	var drop=load("res://objets/body_parts/%s.tscn" % item_aux._name).instantiate()
			
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

func _on_area_2d_area_entered(area: Area2D) -> void:
	mouse_on_this_slot=true
	user_interface.mouse_on_a_slot=true

func _on_area_2d_area_exited(area: Area2D) -> void:
	user_interface.mouse_on_a_slot=false
	mouse_on_this_slot=false
