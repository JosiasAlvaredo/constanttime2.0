extends State_base

var boss: Boss

@export var projectile_scene: PackedScene
@export var shoot_delay := 0.4
@export var cooldown := 0.3

var shooting := false


func start() -> void:
	boss = controlled_node
	shooting = false
	
	await get_tree().create_timer(shoot_delay).timeout
	
	if state_machine.current_state != self:
		return
	
	shoot_projectile()


func shoot_projectile() -> void:
	if shooting:
		return
	
	if projectile_scene == null:
		push_error("No se asignó el proyectil en Shoot")
		state_machine.change_to("Idle")
		return
	
	if boss.playerUbi == null:
		state_machine.change_to("Idle")
		return
	
	shooting = true
	
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	
	var shoot_point: Marker2D = boss.get_node("ShootPoint")
	
	projectile.global_position = shoot_point.global_position
	
	var direction := (boss.playerUbi.global_position - shoot_point.global_position).normalized()
	
	projectile.direction = direction
	
	await get_tree().create_timer(cooldown).timeout
	
	if state_machine.current_state == self:
		state_machine.change_to("Idle")


func end() -> void:
	shooting = false
