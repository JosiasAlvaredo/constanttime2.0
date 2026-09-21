extends Node2D
class_name Fluid2D


@export_category("Fluid")

@export var fluid_name: String = "Water"


@export_category("Damage")

@export var causes_damage: bool = false
@export var damage: int = 35


@export_category("Interaction")

@export var splash_on_enter: bool = true
@export var splash_on_exit: bool = true
@export var splash_on_jump: bool = true
@export var splash_on_fall: bool = true
@export var splash_on_movement: bool = true


@onready var damage_area: Area2D = $DamageArea
@onready var splash_detector: Area2D = $SplashDetector


func _ready() -> void:
	damage_area.area_entered.connect(_on_damage_area_entered)
	splash_detector.body_entered.connect(_on_splash_body_entered)
	splash_detector.body_exited.connect(_on_splash_body_exited)


func _on_damage_area_entered(area: Area2D) -> void:
	if not causes_damage:
		return

	if area.get_collision_layer_value(3):
		print("Jugador recibió daño del fluido")


func _on_splash_body_entered(body: Node2D) -> void:
	if not body is Player:
		return

	print("Jugador entró al fluido")


func _on_splash_body_exited(body: Node2D) -> void:
	if not body is Player:
		return

	print("Jugador salió del fluido")
