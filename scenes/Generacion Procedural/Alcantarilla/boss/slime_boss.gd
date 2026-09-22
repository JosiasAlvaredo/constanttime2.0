extends enemy_base

@onready var core_back: AnimatedSprite2D = $core/core_back
@onready var core_gem: Sprite2D = $core/core_gem
@onready var core_front: AnimatedSprite2D = $core/core_front

	
func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
