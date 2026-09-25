extends Area2D

@export_file("*.tscn") var boss_scene_path: String


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:

	if boss_scene_path.is_empty():
		push_warning("No se ha asignado una escena de jefe.")
		return

	get_tree().change_scene_to_file(boss_scene_path)
