extends CharacterBody2D
class_name Stats

@export var speed=300
@export var Jump_stength=-300

@export var Climb_velocity=-150
@export var roll_velocity=600

var can_roll=true

func delay_roll():
	can_roll=false
	await get_tree().create_timer(0.4).timeout
	can_roll=true
	print("can_roll")
