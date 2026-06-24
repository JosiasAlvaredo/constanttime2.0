extends Area2D

var boss

func _ready():
	boss = get_tree().get_first_node_in_group("boss")


func _on_body_entered(body):
	if body.is_in_group("player"):
		if boss != null:
			boss.activate()
		queue_free()
