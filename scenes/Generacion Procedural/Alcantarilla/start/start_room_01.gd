extends Node2D


func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	$Player.state_machine.change_to("Enter_room")
		
		


func _on_stop_body_entered(body: Node2D) -> void:
	$Player.state_machine.change_to("Idle")
