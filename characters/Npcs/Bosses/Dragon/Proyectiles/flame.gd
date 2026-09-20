extends Area2D

@export var max_distance := 600.0
@export var grow_speed := 1200.0
@export var flame_width := 30.0

@export var falling_fire_scene: PackedScene

var direction := Vector2.RIGHT
var current_distance := 0.0
var player_position := Vector2.ZERO

@onready var ray_cast: RayCast2D = $RayCast2D
@onready var line: Line2D = $Line2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var rectangle: RectangleShape2D = $CollisionShape2D.shape


func _ready() -> void:
	direction = direction.normalized()

	ray_cast.target_position = direction * max_distance
	ray_cast.enabled = true

	ray_cast.force_raycast_update()

	update_flame()


func _process(_delta: float) -> void:
	update_flame()


func update_flame() -> void:
	var target_distance := max_distance

	current_distance = move_toward(
		current_distance,
		target_distance,
		grow_speed * get_process_delta_time()
	)

	# VISUAL

	line.points = [
		Vector2.ZERO,
		direction * current_distance
	]

	line.width = flame_width

	# SPRITE

	if sprite.texture:
		sprite.position = direction * current_distance / 2.0
		sprite.rotation = direction.angle()

		sprite.scale.x = current_distance / sprite.texture.get_width()
		sprite.scale.y = flame_width / sprite.texture.get_height()

	# COLISIÓN

	rectangle.size = Vector2(
		current_distance,
		flame_width
	)

	collision.position = direction * current_distance / 2.0
	collision.rotation = direction.angle()


func finish_flame() -> void:
	create_falling_fire()
	queue_free()


func create_falling_fire() -> void:
	if falling_fire_scene == null:
		push_error("No se asignó FallingFire.tscn")
		return

	var fire = falling_fire_scene.instantiate()

	get_tree().current_scene.add_child(fire)

	# El fuego cae exactamente donde estaba el jugador
	fire.global_position = player_position
