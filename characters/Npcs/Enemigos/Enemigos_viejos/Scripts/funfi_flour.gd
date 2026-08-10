extends enemy_base

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var hitbox_collition= $Hitbox/CollisionShape2D2

var animations={ "idle":"Default", "charge":"Charge", "attack":"Attack"}


func _on_start_attack_area_entered(area: Area2D) -> void:
	if state_machine.current_state==$State_Machine/Idle:
		state_machine.change_to("Attack")
		
func _on_start_attack_body_entered(body: Node2D) -> void:
	if state_machine.current_state==$State_Machine/Idle:
		state_machine.change_to("Attack")
