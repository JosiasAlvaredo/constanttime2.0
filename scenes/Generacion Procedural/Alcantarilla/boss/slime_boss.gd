extends enemy_base

@onready var core_back: AnimatedSprite2D = $core/core_back
@onready var core_gem: Sprite2D = $core/core_gem
@onready var core_front: AnimatedSprite2D = $core/core_front

@onready var rain: Area2D = $Node2D/Rain

var start_live=0

func _ready() -> void:
	await get_tree().create_timer(0.01).timeout
	start_live=live
	
func _physics_process(delta: float) -> void:
	rain.max_wait_time=(float(live)/start_live)*10
	print(rain.max_wait_time,"- mwt")
	
func _on_hitbox_area_entered(area: Area2D) -> void:
	core_back.play("damage")
	core_front.play("damage")
	enemy_damage(area.get_parent())
	
	await get_tree().create_timer(4.0/5.0).timeout
	core_back.play("default")
	core_front.play("default")
