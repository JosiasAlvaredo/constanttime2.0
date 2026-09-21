extends enemy_base

@export var max_distance := 600.0
@export var grow_speed := 1200.0
@export var flame_width := 30.0

@export var falling_fire_scene: PackedScene

var direction_player := Vector2.RIGHT
var current_distance := 0.0
var player_position := Vector2.ZERO

@onready var ray_cast: RayCast2D = $RayCast2D
@onready var line: Line2D = $Line2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var rectangle: RectangleShape2D = $Area2D/CollisionShape2D.shape


func _ready() -> void:
	# La dirección ya fue proporcionada por el estado Flame
	ray_cast.target_position = direction_player * max_distance
	ray_cast.enabled = true
	ray_cast.force_raycast_update()

	update_flame()


func _process(_delta: float) -> void:
	update_flame()


func update_flame() -> void:
	current_distance = move_toward(
		current_distance,
		max_distance,
		grow_speed * get_process_delta_time()
	)

	# LINEA

	line.points = [
		Vector2.ZERO,
		direction_player * current_distance
	]

	line.width = flame_width

	# SPRITE

	if sprite.texture:
		sprite.position = direction_player * current_distance / 2.0
		sprite.rotation = direction_player.angle()

		sprite.scale.x = current_distance / sprite.texture.get_width()
		sprite.scale.y = flame_width / sprite.texture.get_height()

	# COLISIÓN

	rectangle.size = Vector2(
		current_distance,
		flame_width
	)

	collision.position = direction_player * current_distance / 2.0
	collision.rotation = direction_player.angle()


func finish_flame() -> void:
	create_falling_fire()
	queue_free()


func create_falling_fire() -> void:
	if falling_fire_scene == null:
		push_error("No se asignó FallingFire.tscn")
		return

	var fire = falling_fire_scene.instantiate()

	get_tree().current_scene.add_child(fire)

	# Aparece exactamente donde estaba el jugador
	# cuando comenzó el ataque
	fire.global_position = player_position
