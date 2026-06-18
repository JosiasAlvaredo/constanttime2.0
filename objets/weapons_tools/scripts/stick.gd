extends weapond_item_base_class
class_name Mele_base

@onready var mele_front_collition: CollisionShape2D = $Mele_front/CollisionShape2D
@onready var mele_down_collition: CollisionShape2D = $Mele_down/CollisionShape2D
@onready var mele_up_collition: CollisionShape2D = $Mele_up/CollisionShape2D

var current_state
func use(State):
	current_state=State
	if Input.is_action_pressed("Up"):
		mele_up_collition.disabled=false
	elif Input.is_action_pressed("Crouch") and not player.is_on_floor():
		mele_down_collition.disabled=false
	else:
		mele_front_collition.disabled=false
	await get_tree().create_timer(0.2).timeout
	mele_front_collition.disabled=true
	mele_down_collition.disabled=true
	mele_up_collition.disabled=true
	player.state_machine.change_to(State)
	player.hand_using=""

		
func _on_mele_down_area_entered(area: Area2D) -> void:
	worn_out()
	player.velocity.y=-recoil

func _on_mele_down_body_entered(body: Node2D) -> void:
	worn_out()
	player.velocity.y=-recoil


func _on_mele_up_area_entered(area: Area2D) -> void:
	worn_out()
	player.velocity.y=-recoil


func _on_mele_up_body_entered(body: Node2D) -> void:
	worn_out()
	player.velocity.y=-recoil

func _on_mele_front_area_entered(area: Area2D) -> void:
	worn_out()
	player.velocity.x=recoil* -sign(player.animated_sprite_2d.scale.x)

func _on_mele_front_body_entered(body: Node2D) -> void:
	worn_out()
	player.velocity.x=recoil* -sign(player.animated_sprite_2d.scale.x)
