extends Node2D

@onready var animation_intro = $AnimationPlayer

func _ready() -> void:
	animation_intro.play("Intro")
	get_tree().create_timer(5).timeout.connect(start_menu)

func start_menu():
	get_tree().change_scene_to_file("res://interface/menu/menu.tscn")
