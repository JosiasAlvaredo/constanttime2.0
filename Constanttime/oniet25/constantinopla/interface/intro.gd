extends CanvasLayer

@onready var intro = $AnimationPlayer

var tiempo = 3

func _ready() -> void:
	intro.play("intro")
	get_tree().create_timer(tiempo).timeout.connect(ida)

func ida () -> void:
	intro.play("ida")
	get_tree().create_timer(tiempo).timeout.connect(menu)

func menu () -> void:
	get_tree().change_scene_to_file("res://interface/menu/menu.tscn")
