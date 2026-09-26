extends Marker2D
class_name EnemySpawner2D

@export_category("Enemies")
@export var enemy_scenes: Array[PackedScene] = []

@export_category("Spawn")
@export_range(1, 100, 1) var enemy_amount: int = 5
@export var spawn_radius: float = 50.0
@export var random_position: bool = true
var spawned_enemies: Array[Node2D] = []


func _ready() -> void:
	spawn_enemies()


func spawn_enemies() -> void:
	for i in range(enemy_amount):
		spawn_enemy()


func spawn_enemy() -> void:
	if enemy_scenes.is_empty():
		print("ERROR: EnemySpawner no tiene escenas asignadas")
		return

	var enemy_scene: PackedScene = enemy_scenes.pick_random()
	print("Generando enemigo: ", enemy_scene.resource_path)

	var enemy = enemy_scene.instantiate() 

	if enemy == null:
		print("ERROR: La escena no tiene un Node2D como nodo raíz")
		return
	
	

	enemy.position =Vector2.ZERO
	enemy.z_index=1000
	add_child(enemy)
	
	spawned_enemies.append(enemy)
