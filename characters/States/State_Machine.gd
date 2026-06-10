extends Node
class_name State_Machine

@onready var controlled_node = self.owner

@export var default_state:State_base

var current_state:State_base=null

func _ready() -> void:
	call_deferred("_state_default_start")

func _state_default_start():
	current_state=default_state
	_state_start()
	
func _state_start():

	current_state.controlled_node=controlled_node
	current_state.state_machine=self
	current_state.start()
	
func change_to(new_state:String):
	if current_state and current_state.has_method("end"): current_state.end()
	current_state= get_node(new_state)
	_state_start()
	
	
func _process(delta:float) -> void:
	if current_state and current_state.has_method("on_process"):
		current_state.on_process(delta)

func _physics_process(delta:float) -> void:
	if GlobalValues.is_dialogue_active:
		
		change_to("Idle")
	if current_state and current_state.has_method("on_physics_process"):
		
		current_state.on_physics_process(delta)

func _input(event: InputEvent) -> void:
	if GlobalValues.is_dialogue_active:
		return
	if current_state and current_state.has_method("on_input") and (controlled_node is Player):
		current_state.on_input(event)

func _unhandled_input(event: InputEvent) -> void:
	if current_state and current_state.has_method("on_unhandled_input") and (controlled_node is Player):
		current_state.on_unhandled_input(event)

func _unhandled_key_input(event: InputEvent) -> void:
	if current_state and current_state.has_method("on_unhandled_key_input") and (controlled_node is Player):
		current_state.on_unhandled_key_input(event)
		
