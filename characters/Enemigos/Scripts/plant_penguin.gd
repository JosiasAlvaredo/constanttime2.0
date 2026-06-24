extends enemy_base

@onready var tongue_area: Area2D = $Tongue_area
@onready var tongue_ray: RayCast2D = $Tongue_ray
@onready var tongue_to_solid_ray: RayCast2D = $TongueToSolid_ray
@onready var tongue_line: Line2D = $Tongue_line

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var trapped_bodies=[]

var animations={ "idle":"default", "move":"Default", "jump":"Default","fall":"Default"}

var current_tongue_size=0

var tongue_velocity=0.00001
var tongue_live=6
func _physics_process(delta: float) -> void:
	var new_size = tongue_line.get_point_count()
	
	if tongue_line.get_point_count()>0:
		tongue_area.scale.x=-tongue_line.get_point_position(tongue_line.get_point_count()-1).x*sign(animated_sprite_2d.scale.x)
		tongue_area.rotation=tongue_to_solid_ray.rotation
	
	
	if tongue_line.get_point_count() <= 0:
		return
	if new_size != current_tongue_size:
		var removed_points = current_tongue_size - new_size
		current_tongue_size = new_size

		for trapped in trapped_bodies:
			var body = trapped[0]
			var point_index = trapped[1]

			point_index -= removed_points

			if point_index>5 and tongue_live>0:
				trapped[1] = point_index

				body.global_position = to_global(tongue_line.get_point_position(point_index))
			else:
				
				trapped[0].trapped=false

				trapped_bodies.erase(trapped)

				
func Flip_to(target):
	var distance=target.global_position.x-global_position.x
	if sign(distance)!=0:
		direction = sign(distance)*abs(animated_sprite_2d.scale.x)
		animated_sprite_2d.scale.x = direction
	
func _on_hitbox_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())


func _on_area_2d_body_entered(body: Node2D) -> void:
	player=body
	state_machine.change_to("Tongue")


func _on_area_2d_body_exited(body: Node2D) -> void:
	state_machine.change_to("Idle")

	


func _on_tongue_area_body_entered(body: Node2D) -> void:
	var current_distance = INF
	var tongue_point_pos = Vector2.ZERO
	var tongue_point=0
	var line_at_the_moment=tongue_line
	
	body.trapped=true
	
	for i in range(line_at_the_moment.get_point_count()):
		var dist = (to_local(body.global_position)- line_at_the_moment.get_point_position(i)).length()

		if dist < current_distance:
			current_distance = dist
			tongue_point_pos = line_at_the_moment.get_point_position(tongue_point)
			tongue_point=i

	body.global_position = to_global(tongue_point_pos)
	current_tongue_size=line_at_the_moment.get_point_count()
	trapped_bodies.append([body,tongue_point])
	


func _on_tongue_area_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(6):
		tongue_velocity/=2
		tongue_live-=area.get_parent().damage
		
