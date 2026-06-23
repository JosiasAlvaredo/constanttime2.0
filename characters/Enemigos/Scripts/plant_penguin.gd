extends enemy_base


@onready var tongue_ray: RayCast2D = $Tongue_ray
@onready var tongue_to_solid_ray: RayCast2D = $TongueToSolid_ray
@onready var tongue_line: Line2D = $Tongue_line
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var animations={ "idle":"default", "move":"Default", "jump":"Default","fall":"Default"}

func Flip_to(target):
	var distance=target.global_position.x-global_position.x
	if sign(distance)!=0:
		direction = sign(distance)*abs(animated_sprite_2d.scale.x)
		animated_sprite_2d.scale.x = direction

func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())


func _on_area_2d_body_entered(body: Node2D) -> void:
	player=body
	state_machine.change_to("Tongue")


func _on_area_2d_body_exited(body: Node2D) -> void:
	state_machine.change_to("Idle")

	
