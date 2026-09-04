extends StaticBody2D

@export var max_wait_time=0.0
@export var height_limit=0
@export var stream_time=0
var wait_time=0

enum State{Shot,StartWait ,Wait}

var current_state=State.Wait

var stream=null

func _ready() -> void:
	await get_tree().create_timer(randf_range(0,max_wait_time)).timeout
	current_state=State.Shot

func _physics_process(delta: float) -> void:
	match current_state:

		State.Shot: shot()
	
		State.StartWait:wait()
		
		
func shot():
	stream=preload("res://objets/Map/Sewer/Stream.tscn").instantiate()
	stream.height_limit=height_limit
	stream.stream_time=stream_time
	add_child(stream)
		
	wait_time=randf_range(0,max_wait_time)
		
	current_state=State.StartWait
	
func wait():
	if stream==null:
		current_state=State.Wait
		await get_tree().create_timer(wait_time).timeout
		current_state=State.Shot
