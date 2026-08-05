extends Stats
class_name Player

@onready var body: Node2D = $body

@onready var state_machine: State_Machine = $State_Machine

@onready var right_hand_sprite: Sprite2D = $"../User_Interface/Right_hand_sprite"
@onready var left_hand_sprite: Sprite2D = $"../User_Interface/Left_hand_sprite"

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var hit_box: Area2D = $Hit_box

@onready var head_ray: RayCast2D = $Head_ray

@onready var user_interface: CanvasLayer = $"../User_Interface"

var Interactive_Box_collition

var body_up: RayCast2D 
var body_down: RayCast2D 

var right_hand_item=null
var left_hand_item=null

var animations={ "idle":"Idle", "move":"Run", "jump":"Jump","fall":"Jump", "crouched":"Crouched", "roll":"Roll", "climbUp":"ClimbUp", "climbDown":"ClimbDown"}

var is_inmunity=false
var hand_using=""

var direction=1
var direction_y=0

var recoil=0

var body_botton=0



func _ready() -> void:
	#buil body
	var torso=load(GlobalValues.bodies_parts.torso).instantiate()

	body.add_child(torso)
	body.move_child(torso, torso.get_index() - 1)
	
	collision_shape_2d.scale.y=abs(body_botton-collision_shape_2d.global_position.y)
	hit_box.scale.y=abs(body_botton-collision_shape_2d.global_position.y)
	
	collision_shape_2d.position.y=(collision_shape_2d.scale.y/2)- 9
	hit_box.position.y=(collision_shape_2d.scale.y/2)- 9
	
	############
	#items
	if GlobalValues.Right_hand.name!="":
		var item = load("res://objets/weapons_tools/%s.tscn" % GlobalValues.Right_hand.name).instantiate()

		item.durability=GlobalValues.Right_hand.durability
		body.add_child(item)
		right_hand_sprite.texture=load("res://assets/items/Weapons/%s.png" % item._name)
		right_hand_sprite.get_child(0).text=str(item.durability)
		right_hand_item=item
	if GlobalValues.Left_hand.name!="":
		var item = load("res://objets/weapons_tools/%s.tscn" % GlobalValues.Left_hand.name)
		
		item.durability=GlobalValues.Left_hand.durability
		body.add_child(item)
		left_hand_sprite.texture=load("res://assets/items/Weapons/%s.png" % item._name)
		left_hand_sprite.get_child(0).text=str(item.durability)
		left_hand_item=item
	############
		
func _physics_process(delta: float) -> void:
	direction=-Input.get_axis("Right","Left")
	direction_y=-Input.get_axis("Up","Crouch")
	
	if activate_Gravity:
		velocity.y+= gravity*delta
		
	if trapped:
		activate_Gravity=false
		solid=false
		state_machine.change_to("Trapped")
	elif state_machine.current_state==$State_Machine/Trapped:
		state_machine.change_to("Idle")
		activate_Gravity=true
		solid=true
		
	move_and_slide()
	
func FLIP():
	body.scale.x=abs(body.scale.x)*direction

func dead():
	GlobalValues.time=60
	get_tree().change_scene_to_file("res://scenes/mundo/Mapa1.tscn")

func damage_player(_damage):
	pass

func inmunity():
	if get_tree():
		is_inmunity=true
		state_machine.change_to("Knockback")
		await get_tree().create_timer(0.75).timeout
		is_inmunity=false

func coyote_timer():
	await get_tree().create_timer(0.2).timeout
	return true

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(3) and not is_inmunity:
		var enemy=area.owner
		damage_player(enemy.damage)
		
		recoil=enemy.knockback
		velocity.x=sign(enemy.global_position.x-global_position.x)
		velocity.y=sign(enemy.global_position.y-global_position.y)
		inmunity()

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		dead()
	elif body.get_collision_layer_value(4):
		dead()
		

func _on_collect_box_area_entered(area: Area2D) -> void:
	var objet=area.get_parent()
	user_interface.near_objets.append(objet)
	

func _on_collect_box_area_exited(area: Area2D) -> void:
	var objet=area.get_parent()
	user_interface.near_objets.pop_at(user_interface.near_objets.find(objet))
