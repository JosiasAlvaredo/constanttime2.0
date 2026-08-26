extends Resource
class_name Weapons

@export var _name=""

@export var max_durability=0
@export var durability=0
@export var damage=0

@export var recoil=100
@export var knockback=Vector2(-100,-100)

enum Effects {fire}

@export var number_effects: Array[Effects] = []
