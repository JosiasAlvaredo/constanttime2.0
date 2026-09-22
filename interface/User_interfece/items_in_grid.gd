extends Button

@onready var durability_node = $Durability

@export var skills=null
@export var _name=null
@export var link_to_original=null

var user_interface




func _ready() -> void:
	await  get_tree().create_timer(0.01).timeout
	user_interface=get_parent().get_parent().get_parent().get_parent().get_parent()
	if skills!=null:
		var durability_percent=float(skills.durability)/skills.max_durability
		durability_node.size.x=durability_percent*51
			
		durability_node.color=Color8(255-255*durability_percent,255*durability_percent,0)

func _on_pressed() -> void:
	if user_interface.selected_body_part==null:
		visible=false
		var aux_item=load("res://interface/User_interfece/slot_items/slot_item.tscn").instantiate()
		aux_item.global_position=global_position
		user_interface.add_child(aux_item)

		aux_item.skills=skills
		aux_item.button.icon=icon
		aux_item.grid_item=self
		aux_item.link_to_original=link_to_original



func _on_mouse_entered() -> void:
	user_interface.analisis(self)
	user_interface.mouse_on_a_slot=true



func _on_mouse_exited() -> void:
	user_interface.timer_clouse_info()
	user_interface.mouse_on_a_slot=false
