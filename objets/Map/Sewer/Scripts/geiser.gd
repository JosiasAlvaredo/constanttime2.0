extends StaticBody2D


@export var activate=true
@export var max_wait_time=0.0
@export var height_limit=0
@export var stream_time=0

@export_enum("Up","Other") var animation="Up"

var wait_time=0

enum State{Shot,StartWait ,Wait}

var current_state=State.Wait

var stream=null

func _ready() -> void:
	await get_tree().create_timer(randf_range(0,max_wait_time)).timeout
	current_state=State.Shot

func _physics_process(delta: float) -> void:
	if get_parent().visible and activate:
		match current_state:

			State.Shot: shot()
		
			State.StartWait:wait()
	else:
		$".".set_collision_layer_value(1,false)
		
func shot():
	stream=preload("res://objets/Map/Sewer/Stream.tscn").instantiate()
	stream.get_child(2).height_limit=height_limit
	stream.get_child(2).stream_time=stream_time
	stream.get_child(2).animation=animation
	add_child(stream)
		
	wait_time=randf_range(0,max_wait_time)
		
	current_state=State.StartWait
	
func wait():
	if stream==null:
		current_state=State.Wait
		await get_tree().create_timer(wait_time).timeout
		current_state=State.Shot
