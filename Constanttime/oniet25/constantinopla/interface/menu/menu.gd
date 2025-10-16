extends CanvasLayer

@onready var clic: AudioStreamPlayer2D = $VBoxContainer/iniciar/AudioStreamPlayer2D

func _on_iniciar_pressed() -> void:
	clic.playing = true
	get_tree().change_scene_to_file("res://scenes/mundo/mundo.tscn")

func _on_opciones_pressed() -> void:
	get_tree().change_scene_to_file("res://interface/menu/opciones.tscn")


func _on_salir_pressed() -> void:
	get_tree().quit() 
