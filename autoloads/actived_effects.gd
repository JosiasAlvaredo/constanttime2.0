extends Node

func fire(target):
	for i in range(5):
		await get_tree().create_timer(1.5).timeout
		if target!=null:
			target.suffer_damage(5)

	if target!=null:
		target.current_effects.erase(fire)


func poison(target):
	for i in range(50):
		await get_tree().create_timer(2).timeout
		if target!=null:
			target.suffer_damage(1)

	if target!=null:
		target.current_effects.erase(poison)
