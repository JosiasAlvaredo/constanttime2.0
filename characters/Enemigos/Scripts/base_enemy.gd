extends Stats
class_name enemy_base

@onready var state_machine: State_Machine = $State_Machine

var direction=1
var last_direction=1

var recoil=0

func enemy_damage(weapond):
	print(live)
	var enemy=weapond.player
	last_direction=direction
	direction=0
	velocity.x=sign(enemy.global_position.x-global_position.x)
	velocity.y=sign(enemy.global_position.y-global_position.y)
	live-=weapond.damage
	recoil=weapond.knockback*Knockback_resistence
	
	if Knockback_resistence!=0:
		print(Knockback_resistence,"xfds")
		state_machine.change_to("Knockback")
		
	if live<=0:
		dead()

func dead():
	queue_free()
