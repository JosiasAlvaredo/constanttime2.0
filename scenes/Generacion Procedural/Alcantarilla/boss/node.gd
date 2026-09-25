extends State_base

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

@export var is_dead=false
@onready var boss_room_trigger: Area2D = $"../../../BossRoomTrigger"

@onready var geiser_2: StaticBody2D = $"../../../map/GeiserTile/Geiser2"
@onready var geiser_4: StaticBody2D = $"../../../map/Geiser4"
@onready var geiser_3: StaticBody2D = $"../../../map/Geiser3"
@onready var geiser_6: StaticBody2D = $"../../../map/GeiserTile2/Geiser6"
@onready var geiser_5: StaticBody2D = $"../../../map/GeiserTile3/Geiser5"

func start():
	
	var geisers=[geiser_2,geiser_3,geiser_4,geiser_3,geiser_6,geiser_5]
	
	for geiser in geisers:
		geiser.activate=false
	
	animation_player.play("Dead")
	controlled_node.core_back.play("damage")
	controlled_node.core_front.play("damage")
	for wall in controlled_node.walls:
		wall.play("wall_damage")

func dead():

		await get_tree().create_timer(1.5).timeout
		controlled_node.rain.drop()
		controlled_node.rain.drop()
		controlled_node.rain.drop()
		controlled_node.rain.drop()
		controlled_node.rain.drop()
		controlled_node.rain.drop()
		controlled_node.rain.drop()
		controlled_node.rain.drop()
		controlled_node.rain.drop()
		
		boss_room_trigger.state=boss_room_trigger.State.CLEARED
		
		controlled_node.queue_free()
	
