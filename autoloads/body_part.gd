extends Resource
class_name body_part

@export var _name=""

@export var durability=0
@export var speed=0
@export var jump_force=0
@export var damage=0

#es el porcentaje de daño q se lleva esta parte (por ahora solo funciona para el torso)
@export var shockwave=0

@export var can_take=false

@export_enum("none","small","medium","big") var size:int

enum Habilities {climb,attack, doble_jump}

@export var number_habilities: Array[Habilities] = []
