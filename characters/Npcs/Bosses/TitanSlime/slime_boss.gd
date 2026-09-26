extends boss_base

@onready var core_back: AnimatedSprite2D = $core/core_back
@onready var core_gem: Sprite2D = $core/core_gem
@onready var core_front: AnimatedSprite2D = $core/core_front

@onready var rain: Area2D = $Node2D/Rain

#Paredes
@onready var roof_1: AnimatedSprite2D = $Node2D/roof_1
@onready var animated_sprite_2d_4: AnimatedSprite2D = $Node2D/AnimatedSprite2D4
@onready var wall_1: AnimatedSprite2D = $Node2D/wall1
@onready var animated_sprite_2d_6: AnimatedSprite2D = $Node2D/AnimatedSprite2D6
@onready var wall_2: AnimatedSprite2D = $Node2D/wall_2
@onready var animated_sprite_2d_8: AnimatedSprite2D = $Node2D/AnimatedSprite2D8
@onready var roof_2: AnimatedSprite2D = $Node2D/roof_2


var walls
	
@onready var _dead: Node = $State_Machine/Dead

	
var start_live=0

func _ready() -> void:
	await get_tree().create_timer(0.01).timeout
	start_live=live
	walls=[roof_1,animated_sprite_2d_4,wall_1,animated_sprite_2d_6,wall_2,animated_sprite_2d_8,roof_2]
	
func _physics_process(delta: float) -> void:
	if _dead.is_dead:
		_dead.dead()
	
	rain.max_wait_time=((float(live)/start_live)*30)
	if live<0:
		live=0
	
func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
	state_machine.change_to("Damage")
	
