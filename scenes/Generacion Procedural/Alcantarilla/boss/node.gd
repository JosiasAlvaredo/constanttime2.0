extends State_base
@export var dead=false

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"


func start():
	animation_player.play("Dead")

func on_physics_process(delta: float) -> void:

	if dead:
		controlled_node.core_back.play("damage")
		controlled_node.core_front.play("damage")
		for wall in controlled_node.walls:
			wall.play("wall_damage")

		await get_tree().create_timer(5).timeout
		controlled_node.rain.drop()
		controlled_node.rain.drop()
		controlled_node.rain.drop()
		controlled_node.rain.drop()
		controlled_node.rain.drop()
		controlled_node.rain.drop()
		controlled_node.rain.drop()
		controlled_node.rain.drop()
		controlled_node.rain.drop()
		controlled_node.queue_free()
	
