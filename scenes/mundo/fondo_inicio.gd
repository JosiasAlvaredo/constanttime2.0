extends Sprite2D
@onready var player=$"../player"
func _physics_process(delta: float) -> void:
	position=player.position
	position.y=player.position.y-20
