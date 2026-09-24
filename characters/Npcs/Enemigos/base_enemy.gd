extends Stats
class_name enemy_base

@export var number_effects: Array[GlobalValues.Effects] = []

@export var nro_drops=1
@export var drops: Array[PackedScene] = []

@onready var state_machine: State_Machine = $State_Machine

var direction=1
var last_direction=1

var recoil=0

var player: Player = null

var aux_values={}

var weight=0

func _init() -> void:
	direction=sign(randf_range(-100,100)+randf_range(-100,100))
	last_direction=direction
	
	
func _process(delta: float) -> void:
	if activate_Gravity:
		velocity += transform.y * gravity * delta
		
	if aux_values=={}:
		aux_values.speed=speed
		aux_values.Jump_stength=Jump_stength

	speed=aux_values.speed-(weight*aux_values.speed/3)
	Jump_stength=aux_values.Jump_stength-(weight*aux_values.Jump_stength/3)

func enemy_damage(weapond):
	var enemy=weapond.player

	last_direction=direction
	direction=0
	
	recoil=weapond.skills.knockback*Knockback_resistence
	velocity.x=sign(enemy.global_position.x-global_position.x)
	velocity.y=sign(enemy.global_position.y-global_position.y)
	
	if Knockback_resistence:
		state_machine.change_to("Knockback")

	for i in weapond.skills.number_effects:
		
		var effect=ActiveEffects[GlobalValues.Effects.keys()[i]]
		if not effect in current_effects:
			print("llego","-",effect)
			current_effects.append(effect)
			effect.call(self)

	suffer_damage(weapond.skills.damage)
	
		

func suffer_damage(_damage):
	if _damage is int:
		damage_efect()
		
		live-=_damage
		if live<=0:
			dead()

func dead():
	
	for drop in drops:
		
		for i in range(nro_drops):
			var new_drop=drop.instantiate()
			new_drop.position=position+Vector2(randf_range(-10,10),randf_range(0,10))
			get_parent().add_child(new_drop)
	queue_free()
	
func damage_efect():
	var default_modulate=modulate
	modulate = Color(1, 0, 0) 
	await get_tree().create_timer(0.25).timeout
	modulate = Color(1, 1, 1)  
