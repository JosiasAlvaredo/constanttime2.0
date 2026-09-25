extends State_base
@export var shot=false

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var geiser_4: StaticBody2D = $"../../../Geiser4"

func start():
	animation_player.play("Blast")

func on_physics_process(delta: float) -> void:
	if shot:
		geiser_4.shot()
		controlled_node.core_back.play("damage")
		controlled_node.core_front.play("damage")
		await get_tree().create_timer(4.0/5.0).timeout
		state_machine.change_to("Idle")
