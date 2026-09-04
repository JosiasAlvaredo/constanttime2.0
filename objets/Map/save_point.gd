extends Area2D


func _on_body_entered(body: Node2D) -> void:
	body.save_point=global_position
	print(8)
