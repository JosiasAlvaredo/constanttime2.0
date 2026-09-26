extends Area2D

@export_file("*.tscn") var boss_scene_path: String

@export var activate=true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if activate:
		activate=false
		await get_tree().create_timer(1).timeout
		activate=true

func _on_body_entered(body: Node2D) -> void:
	print(boss_scene_path.is_empty() , activate)
	if boss_scene_path.is_empty() or not activate:
		push_warning("No se ha asignado una escena de jefe.")
		return

	get_tree().change_scene_to_file(boss_scene_path)
