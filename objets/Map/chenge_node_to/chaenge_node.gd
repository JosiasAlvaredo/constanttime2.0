extends Area2D
@export var nodeName=""


func _on_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://scenes/mundo/"+nodeName+".tscn")
	
