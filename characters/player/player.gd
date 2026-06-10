extends Stats
class_name Player

@onready var body_up: RayCast2D = $AnimatedSprite2D/Body_up
@onready var body_down: RayCast2D = $AnimatedSprite2D/Body_Down
@onready var crouch_ray: RayCast2D = $AnimatedSprite2D/Crouch_ray

@onready var stand_up_collition: CollisionShape2D = $Stand_up_collition
@onready var crouched_collition: CollisionShape2D = $Crouched_collition

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var bullet: RayCast2D = $Bullet
@onready var mele_collision: CollisionShape2D = $AnimatedSprite2D/Mele/CollisionShape2D

@export var Left_hand:Item_base=null
@export var Right_hand:Item_base=null

@onready var hit_box: Area2D = $Hit_box

@onready var Interactive_Box_collition: CollisionShape2D = $AnimatedSprite2D/Interactive_Box/CollisionShape2D

@onready var time_bar=$timer/Time_bar
@onready var death_timer: Timer = $timer/Timer

@onready var state_machine: State_Machine = $State_Machine

var animations={ "idle":"Idle", "move":"Run", "jump":"Jump","fall":"Fall"}

var is_inmunity=false
var hand_using=""

var direction=1
var direction_y=0

func _ready() -> void:
	death_timer.start(GlobalValues.time)
	

func _physics_process(delta: float) -> void:
	timer()
	direction=-Input.get_axis("Right","Left")
	
	direction_y=-Input.get_axis("Up","Crouch")
	
	velocity.y+= gravity*delta
		
		
	bullet.target_position=get_local_mouse_position()
	
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
		state_machine.change_to("Recoil")
		await get_tree().create_timer(1.5).timeout
		is_inmunity=false

func _on_hit_box_area_entered(area: Area2D) -> void:

	if area.get_collision_layer_value(3) and not is_inmunity:
		var time=death_timer.time_left
		var enemy=area.get_parent()
		
		death_timer.stop()
		if time-10<=0:
			dead()
		else:
			death_timer.start(time-10)
		
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
