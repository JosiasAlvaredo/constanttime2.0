extends Area2D

@export var defeated_signal: StringName = &"defeated"

enum State { IDLE, FIGHTING, CLEARED }

var state: State = State.IDLE


func _ready() -> void:
	# Conecta por código; si ya la conectaste en el editor no se duplica.
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if state != State.IDLE:
		return
	state=State.FIGHTING
	
func _on_boss_defeated() -> void:
	if state != State.FIGHTING:
		return
	state = State.CLEARED
