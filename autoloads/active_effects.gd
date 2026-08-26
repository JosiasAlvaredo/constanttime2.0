extends Node

func fire(target):
	for i in range(5):
		await get_tree().create_timer(1.5).timeout
		target.live-=1
		if target.live<=0:
			target.dead()
			
	target.current_effects.erase(fire)
