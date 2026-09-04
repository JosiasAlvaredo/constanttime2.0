extends Area2D

@export var height_limit=0
@export var stream_time=0
@export var damage=40


enum States{Starting,Max_height,Stopping}

var current_state=States.Starting

	

func _physics_process(delta: float) -> void:
	match current_state:
		
		States.Starting:Starting()
		
		States.Stopping:Stopping()
	
func Starting():
	scale.y=move_toward(scale.y,height_limit*2,height_limit*2/10)
	
	if scale.y>=height_limit*2:
		current_state=States.Max_height
		Max_height()
		
func Max_height():
	await get_tree().create_timer(stream_time).timeout
	current_state=States.Stopping
	
func Stopping():
	scale.y=move_toward(scale.y,0,scale.y/200)
	if scale.y<=10:
		queue_free()
		
