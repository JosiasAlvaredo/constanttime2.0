extends CharacterBody2D
class_name Stats

@export var live=1

@export var speed=300
@export var recoil_factor=-300

@export var Jump_stength=-300

@export var Climb_velocity=-150
@export var roll_velocity=600

@export var Knockback=300

var can_roll=true
var can_jump=true

var gravity:float= ProjectSettings.get_setting("physics/2d/default_gravity")


func delay_roll():
	can_roll=false
	await get_tree().create_timer(0.4).timeout
	can_roll=true
	
