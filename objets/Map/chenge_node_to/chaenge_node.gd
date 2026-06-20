extends Area2D
@export var nodeName=""
@export var target_door=""
@export_enum("go_left", "go_right","go_up", "go_down") var kind: String

var start_position=Vector2(0,0)

func _ready() -> void:
	if kind=="go_left":
		start_position=global_position-Vector2(20,0)
		
	if kind=="go_right":
		start_position=global_position+Vector2(20,0)

func _on_body_entered(body: Node2D) -> void:
	GlobalValues.start_door=target_door
	get_tree().change_scene_to_file("res://scenes/mundo/"+nodeName+".tscn")
	
