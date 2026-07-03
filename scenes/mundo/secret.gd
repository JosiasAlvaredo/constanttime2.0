extends Area2D

var tween

func _ready():
	$Over.modulate = Color(1.0,1.0,1.0,1.0)

	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.secret_area_in.connect(_on_player_secret_area_in)
		player.secret_area_out.connect(_on_player_secret_area_out)

	var background = $Over.duplicate()
	background.name = "Behind"
	background.z_index = -5
	background.modulate = Color(0.66, 0.66, 0.66, 1.0)
	background.light_mask = 3
	get_parent().add_child.call_deferred(background)

func _on_player_secret_area_in():
	if tween:
		tween.kill()
	if get_tree() != null:
		tween = get_tree().create_tween().set_trans(Tween. TRANS_CUBIC)
		tween. tween_interval(0.05)
		tween.tween_property($Over, "modulate:a", 0.0, 0.45)

func _on_player_secret_area_out():
	if tween:
		tween.kill()
	if get_tree() != null:
		tween = get_tree().create_tween().set_trans(Tween. TRANS_CUBIC)
		tween.tween_interval(0.05)
		tween. tween_property($Over, "modulate:a", 1.0, 0.45)
