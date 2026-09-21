extends enemy_base
 

@export var acceleration := 500.0 

@export var jump_force := -350.0 
@export var follow_distance := 300.0 

@onready var sprite_2d: Sprite2D = $Sprite2D

@onready var floor_ray: RayCast2D = $RayCasts/FloorRay
@onready var wall_ray: RayCast2D = $RayCasts/FrontRay

 
var playerUbi: Node2D 

 
 
func _ready() -> void: 
	playerUbi = get_tree().get_first_node_in_group("player") 
 
func update_sprite_direction() -> void:
	if direction == 1:
		sprite_2d.flip_h = true
	elif direction == -1:
		sprite_2d.flip_h = false


func get_player_distance() -> float: 
	if playerUbi == null: 
		return INF 
	 
	return global_position.distance_to(playerUbi.global_position) 
 

func is_player_in_range() -> bool: 
	return get_player_distance() <= follow_distance

func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
