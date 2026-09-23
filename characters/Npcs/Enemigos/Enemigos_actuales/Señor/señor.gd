extends enemy_base

@onready var floor_ray: RayCast2D = $AnimatedSprite2D/RayCasts/FloorRay
@onready var wall_ray: RayCast2D = $AnimatedSprite2D/RayCasts/WallRay

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func change_direction() -> void:
	direction *= -1

	$AnimatedSprite2D.scale.x *= -1


func _on_attack_area_area_entered(area: Area2D) -> void:
	if state_machine.current_state==$"State_Machine/Patrol(Sr)":
		state_machine.change_to("Attack(Sr)")


func _on_hitbox_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
