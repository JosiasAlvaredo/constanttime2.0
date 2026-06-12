extends Stats
class_name Player

@onready var body_up: RayCast2D = $AnimatedSprite2D/Body_up
@onready var body_down: RayCast2D = $AnimatedSprite2D/Body_Down
@onready var crouch_ray: RayCast2D = $AnimatedSprite2D/Crouch_ray

@onready var stand_up_collition: CollisionShape2D = $Stand_up_collition
@onready var crouched_collition: CollisionShape2D = $Crouched_collition

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var bullet_ray: RayCast2D = $Bullet

@onready var mele_front_collition: CollisionShape2D = $AnimatedSprite2D/Mele_front/CollisionShape2D
@onready var mele_down_collition: CollisionShape2D = $AnimatedSprite2D/Mele_down/CollisionShape2D
@onready var mele_up_collition: CollisionShape2D = $AnimatedSprite2D/Mele_up/CollisionShape2D


@onready var hit_box: Area2D = $Hit_box

@onready var Interactive_Box_collition: CollisionShape2D = $AnimatedSprite2D/Interactive_Box/CollisionShape2D

@onready var death_timer: Timer = $interfas/timer/Timer
@onready var time_bar: ColorRect = $interfas/timer/Time_bar

@onready var state_machine: State_Machine = $State_Machine

@onready var rigth_hand_sprite: Sprite2D = $interfas/Rigth_hand_sprite
@onready var left_hand_sprite: Sprite2D = $interfas/Left_hand_sprite

var animations={ "idle":"Idle", "move":"Run", "jump":"Jump","fall":"Jump"}

var is_inmunity=false
var hand_using=""

var direction=1
var direction_y=0

var recoil=0

func _ready() -> void:
	death_timer.start(GlobalValues.time)
	
	print(GlobalValues.Right_hand)
	if GlobalValues.Right_hand:
		rigth_hand_sprite.texture=GlobalValues.Right_hand.get_child(0).texture
		rigth_hand_sprite.get_child(0).text=str(GlobalValues.Right_hand.durability)
	if GlobalValues.Left_hand:
		left_hand_sprite.texture=GlobalValues.Left_hand.get_child(0).texture
		left_hand_sprite.get_child(0).text=str(GlobalValues.Left_hand.durability)

func _physics_process(delta: float) -> void:
	timer()
	
	direction=-Input.get_axis("Right","Left")
	direction_y=-Input.get_axis("Up","Crouch")
	
	bullet_ray.target_position=get_local_mouse_position()
	
	velocity.y+= gravity*delta
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
		recoil=enemy.recoil_factor
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




func _on_mele_down_area_entered(area: Area2D) -> void:
	GlobalValues.Left_hand=GlobalValues.Left_hand.use(self)
	velocity.y=-Knockback

func _on_mele_down_body_entered(body: Node2D) -> void:
	GlobalValues.Left_hand=GlobalValues.Left_hand.use(self)
	velocity.y=-Knockback


func _on_mele_up_area_entered(area: Area2D) -> void:
	GlobalValues.Left_hand=GlobalValues.Left_hand.use(self)
	velocity.y=Knockback


func _on_mele_up_body_entered(body: Node2D) -> void:
	GlobalValues.Left_hand=GlobalValues.Left_hand.use(self)
	velocity.y=Knockback


func _on_mele_front_area_entered(area: Area2D) -> void:
	GlobalValues.Left_hand=GlobalValues.Left_hand.use(self)
	velocity.x=Knockback* -sign(animated_sprite_2d.scale.x)

func _on_mele_front_body_entered(body: Node2D) -> void:
	GlobalValues.Left_hand=GlobalValues.Left_hand.use(self)
	velocity.x=Knockback* -sign(animated_sprite_2d.scale.x)
