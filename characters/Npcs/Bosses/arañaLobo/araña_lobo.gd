extends enemy_base
class_name Boss

@export var max_live := 1000

var current_phase := 1

var phase_2_triggered := false
var phase_3_triggered := false

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	live = max_live


func _process(_delta: float) -> void:
	update_phase()


func update_phase() -> void:
	var life_percentage := float(live) / float(max_live)

	if life_percentage <= 0.35 and not phase_3_triggered:
		phase_3_triggered = true
		change_phase(3)

	elif life_percentage <= 0.70 and not phase_2_triggered:
		phase_2_triggered = true
		change_phase(2)


func change_phase(new_phase: int) -> void:
	current_phase = new_phase

	print("Boss entró en fase ", current_phase)
