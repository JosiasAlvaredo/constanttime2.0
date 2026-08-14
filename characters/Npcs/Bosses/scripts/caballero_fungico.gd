extends enemy_base

@export var melee_distance := 60
@export var summon_distance := 150
@export var summon_cooldown := 5.0

@onready var animated_sprite_2d = $AnimatedSprite2D

@onready var attack_collision: CollisionShape2D = $AttackDetector/CollisionShape2D
@onready var attack_detector = $AttackDetector
@export var attack_damage := 20
@export var attack_knockback := Vector2(250, -250)
@export var attack_cooldown := 1.0
@export var r_damage=15
@export var r_knockback=Vector2(-200,-500)

@export var funfi_flour_scene: PackedScene = preload("res://characters/Npcs/Enemigos/Enemigos_viejos/DarkCaves/FunfiFlour.tscn")

var animations={ "WalkL":"WalkL", "Petrified":"Petrified", "WalkR":"WalkR", "AttackL":"AttackL", "AttackR":"AttackR", "Transform":"Transform"}
var player_inside := false
var activated := false
var vulnerable := false
var distance: Vector2
var can_summon := true
var can_attack := true

const SPEED = 5.0
const JUMP_VELOCITY = -400.0

func _process(_delta: float) -> void:
	if activated:
		return
	if Input.is_action_just_pressed("Interactue"):
		activated = true
		state_machine.change_to("Transform")

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta
	
	if player != null:
		distance = player.global_position - global_position
	move_and_slide()

func player_is_right() -> bool:
	return player != null and distance.x > 0

func player_is_left() -> bool:
	return player != null and distance.x < 0

func player_distance() -> float:
	return abs(distance.x)

func _on_interaccion_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		player_inside = true


func _on_interaccion_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		player_inside = false

func spawn_funfi_flour():
	var offsets = [-120, -60, 0, 60, 120]
	
	for offset in offsets:
		var flour = funfi_flour_scene.instantiate()
		get_parent().add_child(flour)
		flour.global_position = player.global_position + Vector2(offset, 0)
		await get_tree().create_timer(0.2).timeout


func _on_cuerpo_area_entered(area: Area2D) -> void:
	enemy_damage(area.owner)
	print(live)
