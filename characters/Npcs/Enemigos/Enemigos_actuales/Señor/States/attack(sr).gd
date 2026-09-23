extends State_base

@export var animation_name := "Attack"


func start() -> void:
	controlled_node.animated_sprite_2d.play("default")
	var enemy = controlled_node

	enemy.animation_player.play(animation_name)


func on_physics_process(delta: float) -> void:
	var enemy = controlled_node

	enemy.velocity.x = 0
	enemy.move_and_slide()
	
	if not controlled_node.animation_player.is_playing():
		state_machine.change_to("Patrol(Sr)")
		
