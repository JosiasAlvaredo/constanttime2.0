extends enemy_base

@export var chase_speed: float = 180.0

@onready var sprite = $AnimatedSprite2D
@onready var explosion_area: Area2D = $ExplosionArea
@onready var wall_ray: RayCast2D = $RayCasts/FrontRay
@onready var player_ray: RayCast2D = $RayCasts/PlayerRay
@onready var floor_ray: RayCast2D = $RayCasts/FloorRay

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	update_rays()
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	update_rays()
	move_and_slide()

func update_rays() -> void:
	wall_ray.target_position.x = 30.0 * direction
	floor_ray.position.x = 18.0 * direction
	player_ray.target_position.x = 300.0 * direction

	sprite.flip_h = direction < 0

func _on_explosion_area_body_entered(body: Node2D) -> void:
	player = body
	state_machine.change_to("Explode(exploSqueleton)")
	
func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
