extends weapond_item_base_class
class_name Mele_base

@onready var mele_front_collition: CollisionShape2D = $Mele_front/CollisionShape2D
@onready var mele_down_collition: CollisionShape2D = $Mele_down/CollisionShape2D
@onready var mele_up_collition: CollisionShape2D = $Mele_up/CollisionShape2D

@onready var animated_front: AnimatedSprite2D = $Animated_front
@onready var animated_down: AnimatedSprite2D = $Animated_down
@onready var animated_up: AnimatedSprite2D = $Animated_up

var using=false

var current_state
func use(State):
	current_state=State
	if Input.is_action_pressed("Up"):
		mele_up_collition.disabled=false
		animated_up.play("Attack")
	elif Input.is_action_pressed("Crouch") and not player.is_on_floor():
		mele_down_collition.disabled=false
		animated_down.play("Attack")
	else:
		mele_front_collition.disabled=false
		animated_front.play("Attack")
		
	await get_tree().create_timer(0.2).timeout
	mele_front_collition.disabled=true
	mele_down_collition.disabled=true
	mele_up_collition.disabled=true
	
	animated_front.play("default")
	animated_down.play("default")
	animated_up.play("default")
	player.state_machine.change_to(State)
	player.hand_using=""

		
func _on_mele_down_area_entered(area: Area2D) -> void:
	worn_out()
	using=true
	player.velocity.y=-recoil

func _on_mele_down_body_entered(body: Node2D) -> void:
	if not using:
		worn_out()
		player.velocity.y=-recoil


func _on_mele_up_area_entered(area: Area2D) -> void:
	worn_out()
	using=true
	player.velocity.y=-recoil


func _on_mele_up_body_entered(body: Node2D) -> void:
	if not using:
		worn_out()
		player.velocity.y=-recoil

func _on_mele_front_area_entered(area: Area2D) -> void:
	worn_out()
	using=true
	player.velocity.x=recoil* -sign(player.body.scale.x)

func _on_mele_front_body_entered(body: Node2D) -> void:
	if not using:
		worn_out()
		player.velocity.x=recoil* -sign(player.body.scale.x)
