extends enemy_base

@export var stomp_velocity=100
@export var large_sword_knockback=Vector2(-200,-500)
@export var short_sword_knockback=Vector2(-200,-200)

@export var large_sword_damage=15
@export var short_sword_damage=7
@export var stomp_damage=13

@onready var animated_sprite_2d = $AnimatedSprite2D

@onready var collision_short_sword: CollisionShape2D = $AnimatedSprite2D/Short_sword/CollisionShape2D
@onready var collision_large_sword: CollisionShape2D = $AnimatedSprite2D/Large_sword/CollisionShape2D

var player=null


var distance=0
var animations={ "idle":"Default", "large_sword":"Large_sword", "short_sword":"Short_sword","teleport":"teleport_charge"}

func FLIP():
	if sign(distance.x)!=0:
		direction = sign(distance.x)
		$AnimatedSprite2D.scale.x = direction


func _physics_process(delta):
	if player!=null:
		distance=player.global_position-global_position
		#print(distance)
	
	move_and_slide()


func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.owner)
	print(live)


func _on_start_figth_body_entered(body: Node2D) -> void:
	player=body
	state_machine.change_to("Idle_vartime")
