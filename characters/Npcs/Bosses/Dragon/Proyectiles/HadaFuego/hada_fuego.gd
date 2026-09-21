extends CharacterBody2D

@export var speed := 60.0

var playerUbi: Node2D = null


func _physics_process(_delta: float) -> void:

	if playerUbi == null:
		return

	var direccion := (
		playerUbi.global_position - global_position
	).normalized()

	velocity = direccion * speed

	move_and_slide()
