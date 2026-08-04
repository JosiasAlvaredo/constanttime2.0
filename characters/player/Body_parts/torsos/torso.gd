extends Node2D
@onready var right_arm_position: Node2D = $right_arm_position
@onready var left_arm_position: Node2D = $left_arm_position
@onready var legs_position: Node2D = $legs_position


func _ready() -> void:

	var right_arm=load(GlobalValues.bodies_parts.right_arm).instantiate()
	right_arm.position=right_arm_position.position
	right_arm.z_index=1
	
	var left_arm=load(GlobalValues.bodies_parts.left_arm).instantiate()
	left_arm.position=left_arm_position.position
	
	var legs=load(GlobalValues.bodies_parts.legs).instantiate()
	legs.position=legs_position.position
	
	add_child(right_arm)
	add_child(left_arm)
	add_child(legs)
	owner.body_botton=legs.foot_position.global_position.y
	owner.body_up=$Body_up
	owner.body_down=$Body_Down
