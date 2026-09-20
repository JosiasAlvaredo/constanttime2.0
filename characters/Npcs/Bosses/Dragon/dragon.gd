extends CharacterBody2D
class_name Dragon

@export var live := 1000

var playerUbi: Node2D = null

@onready var state_machine: State_Machine = $State_Machine

func _ready() -> void:
	playerUbi = get_tree().get_first_node_in_group("player")
