extends Area2D


func _on_body_entered(body: Node2D) -> void:
	GlobalValues.llave=true
	queue_free()
