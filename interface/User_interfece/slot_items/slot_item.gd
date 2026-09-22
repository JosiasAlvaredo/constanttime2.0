extends Node2D

@export var parent=null
@export var skills=null

@onready var button: Button = $Button
@onready var durability_node = $Durability

var can_drop=false

var link_to_original=null
var drop=null

var grid_item=null

func _ready() -> void:
	parent=get_parent()
	
	await  get_tree().create_timer(0.01).timeout
	

	if parent.selected_body_part==null:
		parent.selected_body_part=self
		can_drop=false
		timer()
	


	var durability_percent=float(skills.durability)/skills.max_durability
	durability_node.size.x=durability_percent*53
		
	durability_node.color=Color8(255-255*durability_percent,255*durability_percent,0)
	if link_to_original!=null:
		drop=link_to_original.duplicate()
	
func _physics_process(delta: float) -> void:
	global_position=get_global_mouse_position()
	if (Input.is_action_just_pressed("Left_hand") and not parent.mouse_on_a_slot and can_drop) or Input.is_action_just_pressed("Inventory"):
		if not grid_item == null:
			grid_item.visible=true
		parent.selected_body_part=null
		queue_free()

		
func timer():
	await get_tree().create_timer(0.5).timeout
	can_drop=true
	
func delete():
	if link_to_original!=null:
		link_to_original.queue_free()
	if grid_item!=null:
		grid_item.queue_free()
	queue_free()
	

	
func check_player(user_interface):
	if parent==null:
		parent=user_interface
