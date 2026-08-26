extends Node2D

@export var _name=""
@export var durability=0
@export var parent=null
@export var kind=[]

@onready var button: Button = $Button
@onready var durability_node = $Durability

var path

var save_position=Vector2.ZERO
var can_drop=false

var link_to_original=null
var drop=null


func _ready() -> void:
	var skill
	
	parent=get_parent().get_parent().get_parent().get_parent()
	await  get_tree().create_timer(0.1).timeout
	
	skill=load("res://objets/body_parts/skills/%s.tres" % _name)
	if skill==null:
		skill=load("res://objets/items/skills/%s.tres" % _name)
	else:
		skill=skill.duplicate()
	position=save_position
	
	var durability_percent=float(durability)/skill.max_durability
	durability_node.size.x=durability_percent*53
		
	durability_node.color=Color8(255-255*durability_percent,255*durability_percent,0)
	if link_to_original!=null:
		drop=link_to_original.duplicate()
	
func _physics_process(delta: float) -> void:
	if parent.selected_body_part==self:
		global_position=get_global_mouse_position()
		button.mouse_filter=Control.MOUSE_FILTER_IGNORE
	else:
		button.mouse_filter=Control.MOUSE_FILTER_PASS
	if Input.is_action_just_pressed("Left_hand") and not parent.mouse_on_a_slot and can_drop:
		position=save_position
		can_drop=false
		parent.selected_body_part=null

func _on_button_button_down() -> void:
	if parent.selected_body_part==null:
		parent.selected_body_part=self
		can_drop=false
		timer()
		
func timer():

	await get_tree().create_timer(0.5).timeout
	can_drop=true
	
func delete():
	if link_to_original!=null:
		link_to_original.queue_free()
	queue_free()
	
func damage(_damage):
	durability-=_damage
	if durability<=0:
		parent.rebuil_body()
		delete()

func _on_button_mouse_entered() -> void:
	parent.analisis(self)

func _on_button_mouse_exited() -> void:
	parent.timer_clouse_info()
	
func check_player(user_interface):
	if parent==null:
		parent=user_interface
