extends Area2D
@export var zona=""
@export var _name=""

func _on_body_entered(body: Node2D) -> void:
	GlobalValues[zona][name]=true
	queue_free()
