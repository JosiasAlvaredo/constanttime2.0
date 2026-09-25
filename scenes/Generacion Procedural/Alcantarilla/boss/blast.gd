extends State_base
@export var shot=false

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var geiser_4: StaticBody2D = $"../../../Geiser4"

var slime_ball=preload("res://characters/Npcs/Enemigos/Enemigos_actuales/SlimeBall/slimeBall.tscn").instantiate()

var cords=[Vector2(50,232.0),Vector2(294,90.0),Vector2(573,90.0),Vector2(860,232.0)]
var directions=[Vector2(1,0.75),Vector2(0.25,1),Vector2(-0.25,1),Vector2(1,0.75)]





func start():
	animation_player.play("shot_bals")
	for i in range(4):
		await  get_tree().create_timer(0.5).timeout
		var ball=slime_ball.duplicate()
		
		
		
		ball.position=cords[i]
		ball.vectorDirection=directions[i]
		owner.add_child(ball)
	animation_player.play("RESET")
	state_machine.change_to("Idle")
		
