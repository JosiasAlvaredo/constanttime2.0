extends Area2D
@onready var exclamation=$Exclamation
const DIALOGO_MAGO = preload("uid://cuuq13xsgnss")

var si_esta_cerca = false

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _process(delta: float) -> void:
	if si_esta_cerca and Input.is_action_just_pressed("talk") and not GlobalValues.is_dialogue_active:
		DialogueManager.show_dialogue_balloon(DIALOGO_MAGO)

func _on_dialogue_started(dialogue):
	GlobalValues.is_dialogue_active = true
	
func _on_dialogue_ended(dialogue):
	await get_tree().create_timer(0.2).timeout
	GlobalValues.is_dialogue_active = false
	
func _on_area_entered(area):
	si_esta_cerca = true
	exclamation.visible=true
	
func _on_area_exited(area):
	si_esta_cerca = false
	exclamation.visible=false
