extends Node2D
@onready var doors: Node2D = $Doors
@onready var player: Player = $Player


func _ready() -> void:
	var doors=doors.get_children()
	var start_door=GlobalValues.start_door
	if start_door!="":
		for door in doors:
			if door.name==start_door:
				GlobalValues.start_door=""
				player.global_position=door.start_position
		
