extends enemy_base

var playerUbi: Node2D = null


func _ready() -> void:
	playerUbi = get_tree().get_first_node_in_group("player")
	


func _on_hitbox_cabeza_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())


func _on_hitbox_izq_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())


func _on_hitbox_der_area_entered(area: Area2D) -> void:
	enemy_damage(area.get_parent())
