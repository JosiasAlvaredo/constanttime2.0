extends Stats
class_name Player

@onready var body_up: RayCast2D = $AnimatedSprite2D/Body_up
@onready var body_down: RayCast2D = $AnimatedSprite2D/Body_Down
@onready var crouch_ray: RayCast2D = $AnimatedSprite2D/Crouch_ray

@onready var stand_up_collition: CollisionShape2D = $Stand_up_collition
@onready var crouched_collition: CollisionShape2D = $Crouched_collition

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D



@onready var hit_box: Area2D = $Hit_box

@onready var Interactive_Box_collition: CollisionShape2D = $AnimatedSprite2D/Interactive_Box/CollisionShape2D

@onready var death_timer: Timer = $interfas/timer/Timer
@onready var time_bar: ColorRect = $interfas/timer/Time_bar

@onready var state_machine: State_Machine = $State_Machine

@onready var right_hand_sprite: Sprite2D = $interfas/Right_hand_sprite
@onready var left_hand_sprite: Sprite2D = $interfas/Left_hand_sprite

var right_hand_item=null
var left_hand_item=null

var animations={ "idle":"Idle", "move":"Run", "jump":"Jump","fall":"Jump"}

var is_inmunity=false
var hand_using=""

var direction=1
var direction_y=0

var recoil=0

func _ready() -> void:
	death_timer.start(GlobalValues.time)
		
	if GlobalValues.Right_hand.name!="":
		var item = load("res://objets/weapons_tools/%s.tscn" % GlobalValues.Right_hand.name).instantiate()
		
		item.durability=GlobalValues.Right_hand.durability
		animated_sprite_2d.add_child(item)
		right_hand_sprite.texture=item.item_texture
		right_hand_sprite.get_child(0).text=str(item.durability)
		right_hand_item=item
	if GlobalValues.Left_hand.name!="":
		var item = load("res://objets/weapons_tools/%s.tscn" % GlobalValues.Left_hand.name).instantiate()
		
		item.durability=GlobalValues.Left_hand.durability
		animated_sprite_2d.add_child(item)
		left_hand_sprite.texture=item.item_texture
		left_hand_sprite.get_child(0).text=str(item.durability)
		left_hand_item=item
		
		
func _physics_process(delta: float) -> void:
	timer()
	
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
	animated_sprite_2d.scale.x=abs(animated_sprite_2d.scale.x)*direction

func dead():
	GlobalValues.time=60
	get_tree().change_scene_to_file("res://scenes/mundo/Mapa1.tscn")


func timer():
	time_bar.size.x=death_timer.time_left
	GlobalValues.time=death_timer.time_left
	if death_timer.time_left == 0:
		dead()
		
func inmunity():
	if get_tree():
		is_inmunity=true
		state_machine.change_to("Knockback")
		await get_tree().create_timer(0.75).timeout
		is_inmunity=false

func _on_hit_box_area_entered(area: Area2D) -> void:

	if area.get_collision_layer_value(3) and not is_inmunity:
		var time=death_timer.time_left
		var enemy=area.owner
		print(enemy)
		death_timer.stop()
		if time-enemy.damage<=0:
			dead()
		else:
			death_timer.start(time-enemy.damage)
		recoil=enemy.knockback
		velocity.x=sign(enemy.global_position.x-global_position.x)
		velocity.y=sign(enemy.global_position.y-global_position.y)
		inmunity()

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		dead()
	elif body.get_collision_layer_value(4):
		dead()
		
func coyote_timer():
	await get_tree().create_timer(0.2).timeout
	return true
