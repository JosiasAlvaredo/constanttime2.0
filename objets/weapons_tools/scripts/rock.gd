extends weapond_item_base_class
class_name Ray_shoot_class

@onready var bullet_ray: RayCast2D = $Bullet
@onready var line_2d: Line2D = $Line2D
	
func use(State):
	var target=bullet_ray.get_collider()
	worn_out()
	if target:
		if target.has_method("enemy_damage"):
			target.enemy_damage(self)
	player.state_machine.change_to(State)
	player.hand_using=""
	
	
func _physics_process(delta: float) -> void:
	scale.x=abs(scale.x)*sign(get_parent().scale.x)
	bullet_ray.target_position=player.get_local_mouse_position()
	line_2d.set_point_position(1,player.get_local_mouse_position())
