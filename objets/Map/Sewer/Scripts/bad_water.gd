extends enemy_base

func _ready() -> void:
	if not get_parent().visible:
		$Area2D.set_collision_layer_value(3,false)
