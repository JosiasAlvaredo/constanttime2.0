extends CanvasLayer

@onready var iniciar: AudioStreamPlayer2D = $VBoxContainer/iniciar/AudioStreamPlayer2D
@onready var opciones: AudioStreamPlayer2D = $VBoxContainer/opciones/AudioStreamPlayer2D
@onready var animation_intro = $AnimationPlayer

func _on_iniciar_pressed() -> void:
	iniciar.playing = true
	animation_intro.play("new_animation")
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/mundo/mundo.tscn")

func _on_opciones_pressed() -> void:
	opciones.playing = true
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://interface/menu/opciones.tscn")


func _on_salir_pressed() -> void:
	get_tree().quit() 

func _ready() -> void:
	animation_intro.play("normal")
