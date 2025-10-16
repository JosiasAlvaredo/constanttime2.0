extends CharacterBody2D
@onready var time_bar=$timer/Icon
@onready var death_timer=$timer/Timer
@onready var tiempo: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var pasos: AudioStreamPlayer2D = $pasos
@onready var sprite=$Icon

var jump_speed=1000
var speed=200
var can_dash=true
var direction=1
var dashing=false
var sicking=false
var sickjump=false
var coyote_time=true
var is_inmunity=false
var is_facing_right = true
var firts=true
func _ready() -> void:
	death_timer.start(GlobalValues.time)

func _physics_process(delta: float) -> void:
	if GlobalValues.is_dialogue_active:
		return
	jump(delta)
	move()
	dash()
	sick()
	timer()
	flip()
	move_and_slide()


func flip():
	if (is_facing_right and velocity.x < 0) or (not is_facing_right and velocity.x > 0):
		sprite.scale.x *= -1
		is_facing_right = not is_facing_right

	
func jump(delta):
	if (is_on_floor() or coyote_time) and Input.is_action_just_pressed("jump"):
		velocity.y=move_toward(velocity.y,-jump_speed,jump_speed/3)
		sprite.play("jump")
	if Input.is_action_just_released("jump") and velocity.y<0:
		velocity.y=0
	
	if not is_on_floor() and not dashing:
		velocity.y+=GlobalValues.gravity*delta
		coyote_timer()
		sprite.play("dash")
	else:
		
		coyote_time=true
	if is_on_floor() or is_on_wall():
		can_dash=true
		
	if sicking and Input.is_action_just_pressed("jump"):
		velocity.y=move_toward(velocity.y,-jump_speed*2,jump_speed/3)
		velocity.x=move_toward(velocity.x,-jump_speed/3*direction,jump_speed/3)
		sickjump=true

func move():
	var get_axis= Input.get_axis("left","right")
	if get_axis:
		if is_on_floor():
			pasos.stream_paused = false
		sprite.play("move")
		velocity.x=move_toward(velocity.x,speed*get_axis,speed/5)
		direction=get_axis
	elif not dashing:
		pasos.stream_paused = true
		velocity.x=move_toward(velocity.x,0,speed/5)
		sprite.play("default")

func dash():
	if Input.is_action_just_pressed("dash") and can_dash:
		dashing=true
		dash_timer()
		if sicking:
			direction*=-1
		can_dash=false
	if dashing:
		sprite.play("dash")
		velocity.x=move_toward(velocity.x,speed*6*direction,speed)
		
func sick():
	var get_axis=Input.get_axis("left","right")
	
	if is_on_wall_only() and not sickjump and get_axis:
		pasos.stream_paused=false
		sprite.play("wall")
		
		if is_facing_right and firts:
			is_facing_right=false
		elif firts:
			is_facing_right=true
		firts=false
		velocity.y=GlobalValues.gravity/40
		sicking=true
		direction=get_axis
	else:
		firts=true
		sicking=false
		sickjump=false
		
func dash_timer():
	await get_tree().create_timer(0.1).timeout
	dashing=false
	if is_on_floor():
		velocity.x=0
	else:
		velocity.x=speed/5
		
func coyote_timer():
	await get_tree().create_timer(0.1).timeout
	coyote_time=false

func timer():
	time_bar.size.x=death_timer.time_left
	GlobalValues.time=death_timer.time_left
	sonido()
	if death_timer.time_left==0:
		GlobalValues.time=60
		get_tree().change_scene_to_file("res://scenes/mundo/mundo.tscn")
	
func inmunity():
	await get_tree().create_timer(1).timeout
	is_inmunity=false

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(3) and not is_inmunity:
		sprite.play("dash")
		var time=death_timer.time_left
		death_timer.stop()
		if time-10<=0:
			death_timer.start(1)
		else:
			death_timer.start(time-10)
		
		var enemy=area.get_parent()

		velocity.x=sign(enemy.position.x-position.x)*-jump_speed/2
		velocity.y=sign(enemy.position.y-position.y)*jump_speed/4
		is_inmunity=true
		inmunity()

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.get_collision_layer_value(4):
		GlobalValues.time=60
		get_tree().change_scene_to_file("res://scenes/mundo/mundo.tscn")

func sonido():
	if death_timer.time_left == 8:
		tiempo.playing = true
