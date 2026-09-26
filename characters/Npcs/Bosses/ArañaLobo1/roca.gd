extends CharacterBody2D

@onready var araña_lobo: ArañaLobo = $"../../ArañaLobo"
@onready var teleport: Area2D = $"../Teleport"

var stop=false


func _physics_process(delta: float) -> void:
	if araña_lobo==null and not stop:
		velocity.x=move_toward(velocity.x,-(position.x+position.y)/20,10)
		velocity += transform.y * GlobalValues.gravity * delta
		teleport.activate=true
		move_and_slide()

	
