extends Stats
class_name enemy_base

@onready var state_machine: State_Machine = $State_Machine

var direction=1
var last_direction=1

var recoil=0

var player: Player = null


var current_effects=[]


func enemy_damage(weapond):
	var enemy=weapond.player
	damage_efect()
	last_direction=direction
	direction=0
	velocity.x=sign(enemy.global_position.x-global_position.x)
	velocity.y=sign(enemy.global_position.y-global_position.y)
	live-=weapond.skills.damage
	recoil=weapond.skills.knockback*Knockback_resistence
	
	for i in weapond.skills.number_effects:
		
		var effect=ActiveEffects[weapond.skills.Effects.keys()[i]]
		if not effect in current_effects:
			current_effects.append(effect)
			effect.call(self)
	if Knockback_resistence!=0:
		state_machine.change_to("Knockback")
		
	if live<=0:
		dead()

func dead():
	queue_free()
	
func damage_efect():
	var default_modulate=modulate
	modulate = Color(1, 0, 0) 
	await get_tree().create_timer(0.25).timeout
	modulate = Color(1, 1, 1)  
