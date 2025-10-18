extends StaticBody2D

var si_esta_cerca = false
const DIALOGO_door = preload("res://Dialogos/text/door.dialogue")

@onready var exclamation=$Exclamation

func _process(delta: float) -> void:
	if si_esta_cerca and Input.is_action_just_pressed("talk") and GlobalValues.llave:
		self.set_collision_layer_value(1,false)
		GlobalValues.llave=false
	if si_esta_cerca and Input.is_action_just_pressed("talk") and not GlobalValues.llave and  not GlobalValues.is_dialogue_active and self.get_collision_layer_value(1):
		DialogueManager.show_dialogue_balloon(DIALOGO_door)

func _on_area_2d_area_entered(area: Area2D) -> void:
	si_esta_cerca = true
	exclamation.visible=true

func _on_area_2d_area_exited(area: Area2D) -> void:
	si_esta_cerca = false
	exclamation.visible=false
