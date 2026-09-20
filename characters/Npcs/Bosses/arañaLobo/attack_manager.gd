extends Node
class_name Boss_Attack_Manager

@onready var boss: Boss = owner

@onready var sweep_attack_i = $"../SweepAttackI"
@onready var sweep_attack_d = $"../SweepAttackD"


func choose_attack() -> String:
	var attacks = [
		"sweep_i",
		"sweep_d"
	]
	
	return attacks.pick_random()


func start_attack(attack_name: String) -> void:
	match attack_name:
		"sweep_i":
			start_sweep_i()
		
		"sweep_d":
			start_sweep_d()


func start_sweep_i() -> void:
	sweep_attack_i.boss = boss
	sweep_attack_i.start()


func start_sweep_d() -> void:
	sweep_attack_d.boss = boss
	sweep_attack_d.start()
