extends Resource
class_name body_part

@export var _name=""

@export var max_durability=0
@export var durability=0
@export var speed=0
@export var jump_force=0
@export var damage=0

#es el porcentaje de daño q se lleva esta parte (por ahora solo funciona para el torso)
@export var shockwave=0

@export var number_kinds: Array[GlobalValues.BodyParts] = [GlobalValues.BodyParts.right_hand, GlobalValues.BodyParts.left_hand]
var kind=[]

@export var can_take=false

@export_enum("none","small","medium","big") var size:int

enum Habilities {climb,use,doble_jump}

@export var number_habilities: Array[Habilities] = []

var current_effects=[]

@export var inmune_effects:Array[GlobalValues.Effects]=[]
@export var bulnerable_effects:Array[GlobalValues.Effects]=[]

var weight=size

func suffer_damage(_damage):
	durability-=_damage

func body_part_damage(_damage,weapond=null):
	print(_damage,"-",weapond)
	suffer_damage(_damage)
	if weapond != null:
		for i in weapond.number_effects:
			var effect=ActiveEffects[GlobalValues.Effects.keys()[i]]
			if not effect in current_effects and not i in inmune_effects:
				current_effects.append(effect)
				effect.call(self)
