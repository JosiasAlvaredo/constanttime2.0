extends enemy_base


@export var follow_distance := 100.0 

@onready var sprite_2d = $AnimatedSprite2D


@onready var wall_ray: RayCast2D = $AnimatedSprite2D/RayCasts/FrontRay
@onready var floor_ray: RayCast2D = $AnimatedSprite2D/RayCasts/FloorRay

 
var playerUbi: Node2D 

 
 
func _ready() -> void: 
	playerUbi = get_tree().get_first_node_in_group("player") 
	
func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta

func get_player_distance() -> float: 
	if playerUbi == null: 
		return INF 
	 
	return global_position.distance_to(playerUbi.global_position) 
 

func is_player_in_range() -> bool: 
	return get_player_distance() <= follow_distance

func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())


func _on_vision_area_area_entered(area: Area2D) -> void:
	state_machine.change_to("Chase")
