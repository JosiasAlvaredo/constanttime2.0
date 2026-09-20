extends enemy_base

@export var time_alive := 5.0


func _ready() -> void:
	await get_tree().create_timer(time_alive).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	move_and_slide()


func on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
