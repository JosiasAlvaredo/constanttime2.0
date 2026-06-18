extends weapond_item_base_class
class_name Ray_shoot_class

@onready var bullet_ray: RayCast2D = $Bullet
	
func use(State):
	var target=bullet_ray.get_collider()
	if target:
		if target.has_method("enemy_damage"):
			target.enemy_damage(self)
	player.state_machine.change_to(State)
	player.hand_using=""
	worn_out()
	
func _physics_process(delta: float) -> void:
	bullet_ray.target_position=player.get_local_mouse_position()
	
