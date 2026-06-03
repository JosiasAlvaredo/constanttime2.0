extends Node
class_name Item_base

@export var durability=1

@export_enum("Bullet", "Mele") var kind: String
func use():
	durability-=1
	if durability<=0:
		return null
	else:
		return self
