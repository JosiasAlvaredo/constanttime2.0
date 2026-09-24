extends Node2D

@export var height_limit=0
@export var stream_time=0
@export var damage=40

@export_enum("Up","Other") var animation="Up"

@export var number_effects: Array[GlobalValues.Effects] = []

enum States{Starting,Shot,Continue,Stopping}

var current_state=States.Starting

@onready var area_2d: Area2D = $"."


	
@onready var animations_sprites= {"Up":$"../up","Other":$"../other"}

func _physics_process(delta: float) -> void:
	match current_state:
		States.Starting:Starting()
		
		States.Shot:Shotting()
		
		States.Stopping:Stopping()
	
func Starting():
	if animation=="Up":
		animations_sprites[animation].scale.y=height_limit/21
	else:
		animations_sprites[animation].scale.x=height_limit/21
	animations_sprites[animation].play("charge")
	current_state=States.Continue
	await get_tree().create_timer(float(5.0/6.0)).timeout
	current_state=States.Shot
	
func Shotting():
	animations_sprites[animation].play("shot")
	
	area_2d.scale.y=move_toward(area_2d.scale.y,height_limit*2,height_limit*2/10)
	
	if area_2d.scale.y>=height_limit*2:
		
		current_state=States.Continue
		Max_height()
		
func Max_height():
	
	animations_sprites[animation].play("wait")
	await get_tree().create_timer(stream_time).timeout
	current_state=States.Stopping
	
func Stopping():
	area_2d.scale.y=move_toward(area_2d.scale.y,0,area_2d.scale.y/200)
	
	if area_2d.scale.y<=height_limit/4:
		animations_sprites[animation].play("stopping_4")
		await get_tree().create_timer(3.0/5.0).timeout
		get_parent().queue_free()
		
	elif area_2d.scale.y<=height_limit/2:
		animations_sprites[animation].play("stopping_3")
		
	elif area_2d.scale.y<=height_limit:
		animations_sprites[animation].play("stopping_2")
		
	elif area_2d.scale.y<=float(height_limit)*1.75:
		animations_sprites[animation].play("stopping_1")
