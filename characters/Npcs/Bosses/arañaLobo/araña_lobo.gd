extends enemy_base
class_name Boss

@export var max_live := 1000

var current_phase := 1

var phase_2_triggered := false
var phase_3_triggered := false

@onready var playerUbi: Player = get_tree().get_first_node_in_group("player")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_manager: Boss_Attack_Manager = $Attack_Manager

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
	
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		state_machine.change_to("Idle")
		
func choose_next_attack() -> void:
	var random_number := randf_range(0.0, 100.0)
	
	if random_number < 10.0:
		state_machine.change_to("Attack")
	else:
		state_machine.change_to("Shoot")
		
func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
	
func _on_hitbox_area_entered_Izq(area: Area2D) -> void:
	enemy_damage(area.get_parent())


func _on_hitbox_area_entered_der(area: Area2D) -> void:
	enemy_damage(area.get_parent())
