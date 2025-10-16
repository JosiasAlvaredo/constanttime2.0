extends Area2D
@export var nodeName=""


func _on_body_entered(body: Node2D) -> void:
	print(9)
	get_tree().change_scene_to_file("res://scenes/mundo/"+nodeName+".tscn")
	
