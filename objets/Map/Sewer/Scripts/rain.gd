extends Area2D

@export var max_wait_time=0.0

var wait_time=0

enum State{Drop,StartWait ,Wait}

var current_state=State.Drop


func _physics_process(delta: float) -> void:
	match current_state:

		State.Drop: drop()
	
		State.StartWait:wait()
		
		
func drop():
	
	var new_droplet=preload("res://objets/Map/Sewer/droplet.tscn").instantiate()
	new_droplet.global_position.y=global_position.y
	new_droplet.global_position.x=randf_range(global_position.x,global_position.x+scale.x)
	get_parent().add_child(new_droplet)
	
	wait_time=randf_range(0,max_wait_time)
	
	current_state=State.StartWait
	
func wait():
	current_state=State.Wait
	await get_tree().create_timer(wait_time).timeout
	current_state=State.Drop
