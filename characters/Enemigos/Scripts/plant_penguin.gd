extends enemy_base


func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
