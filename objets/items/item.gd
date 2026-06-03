extends Area2D


func _on_area_entered(area: Area2D) -> void:
	var parent=get_parent()
	var player=area.get_parent().get_parent()
	if player.hand_using=="Left":
		player.Left_hand=parent
		self.queue_free()
	if player.hand_using=="Right":
		player.Right_hand=parent
		self.queue_free()
