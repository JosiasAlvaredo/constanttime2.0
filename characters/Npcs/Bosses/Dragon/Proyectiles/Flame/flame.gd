extends enemy_base

@export var max_distance := 600.0
@export var grow_speed := 1200.0
@export var flame_width := 30.0
@export var falling_fire_scene: PackedScene

var direction_player := Vector2.RIGHT
var current_distance := 0.0
var player_position := Vector2.ZERO

@onready var ray_cast: RayCast2D = $RayCast2D
@onready var area: Area2D = $Area2D
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var sprite: Sprite2D = $Area2D/Sprite2D
@onready var rectangle: RectangleShape2D = $Area2D/CollisionShape2D.shape


func _ready() -> void:
	update_direction()
	update_flame()


func _process(_delta: float) -> void:
	update_direction()
	update_flame()


func update_direction() -> void:
	if player_position != Vector2.ZERO:
		direction_player = (player_position - global_position).normalized()

	ray_cast.target_position = direction_player * max_distance
	ray_cast.force_raycast_update()


func update_flame() -> void:
	var target_distance := max_distance

	if ray_cast.is_colliding():
		target_distance = global_position.distance_to(
			ray_cast.get_collision_point()
		)

	target_distance = max(target_distance, 1.0)

	current_distance = move_toward(
		current_distance,
		target_distance,
		grow_speed * get_process_delta_time()
	)

	rectangle.size = Vector2(
		current_distance,
		flame_width
	)

	area.position = Vector2.ZERO
	area.rotation = direction_player.angle()

	collision.position = Vector2(
		current_distance / 2.0,
		0
	)

	collision.rotation = 0.0

	if sprite.texture:
		var texture_size := sprite.texture.get_size()

		if sprite.region_enabled:
			texture_size = sprite.region_rect.size

		sprite.position = Vector2(
			current_distance / 2.0,
			0
		)

		sprite.rotation = -PI / 2.0

		sprite.scale = Vector2(
			flame_width / texture_size.x,
			current_distance / texture_size.y
		)


func finish_flame() -> void:
	create_falling_fire()
	queue_free()


func create_falling_fire() -> void:
	if falling_fire_scene == null:
		push_error("❌ No se asignó FallingFire.tscn")
		return

	var fire = falling_fire_scene.instantiate()

	get_tree().current_scene.add_child(fire)

	fire.global_position = player_position
