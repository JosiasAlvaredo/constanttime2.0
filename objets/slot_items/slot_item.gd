extends Button

@onready var button: Button = $Button
@onready var durability: Label = $Durability
@onready var item_sprite: Sprite2D = $sprite

var follow_mouse=false
var parent

var save_position=position

func _ready() -> void:
	parent=get_parent().get_parent().get_parent()

func _physics_process(delta: float) -> void:
	if follow_mouse:
		global_position=get_global_mouse_position()
	if Input.is_action_just_pressed("Right_hand"):
		position=save_position
		follow_mouse=false
		parent.using_mouse=false
	

func _on_button_down() -> void:
	if not parent.using_mouse:
		follow_mouse=true
		parent.using_mouse=true
