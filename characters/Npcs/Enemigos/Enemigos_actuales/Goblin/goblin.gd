extends CharacterBody2D

@export var speed := 100.0
@export var acceleration := 500.0
@export var gravity := 1000.0
@export var jump_force := -350.0
@export var follow_distance := 300.0

@onready var wall_ray: RayCast2D = $RayCasts/FrontRay
@onready var floor_ray: RayCast2D = $RayCasts/FloorRay

var player: Node2D
var direction := 1


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func get_player_distance() -> float:
	if player == null:
		return INF
	
	return global_position.distance_to(player.global_position)


func is_player_in_range() -> bool:
	return get_player_distance() <= follow_distance
