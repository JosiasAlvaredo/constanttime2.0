extends boss_base

@onready var core_back: AnimatedSprite2D = $core/core_back
@onready var core_gem: Sprite2D = $core/core_gem
@onready var core_front: AnimatedSprite2D = $core/core_front

@onready var rain: Area2D = $Node2D/Rain

#Paredes
@onready var animated_sprite_2d_2: AnimatedSprite2D = $Node2D/AnimatedSprite2D2
@onready var animated_sprite_2d_4: AnimatedSprite2D = $Node2D/AnimatedSprite2D4
@onready var animated_sprite_2d_5: AnimatedSprite2D = $Node2D/AnimatedSprite2D5
@onready var animated_sprite_2d_6: AnimatedSprite2D = $Node2D/AnimatedSprite2D6
@onready var animated_sprite_2d_7: AnimatedSprite2D = $Node2D/AnimatedSprite2D7
@onready var animated_sprite_2d_3: AnimatedSprite2D = $Node2D/AnimatedSprite2D3

var walls
	

var start_live=0

func _ready() -> void:
	await get_tree().create_timer(0.01).timeout
	start_live=live
	walls=[animated_sprite_2d_2,animated_sprite_2d_4,animated_sprite_2d_5,animated_sprite_2d_6,animated_sprite_2d_7,animated_sprite_2d_3]
	
func _physics_process(delta: float) -> void:
	rain.max_wait_time=(float(live)/start_live)*30

	
func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
	state_machine.change_to("Damage")
	

func _on_boss_room_trigger_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
