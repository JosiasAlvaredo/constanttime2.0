extends Area2D

## Grupo al que pertenece el jefe (Nodo > Grupos en el editor).
@export var boss_group: StringName = &"boss"
## Si el jefe tiene una señal con este nombre (sin parámetros) se usa para saber
## cuándo murió. Si no la tiene, se detecta cuando el jefe se elimina con queue_free().
@export var defeated_signal: StringName = &"defeated"

enum State { IDLE, FIGHTING, CLEARED }

var state: State = State.IDLE
var boss_room: Node2D = null
var generator: Node = null


func _ready() -> void:
	# Conecta por código; si ya la conectaste en el editor no se duplica.
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if state != State.IDLE:
		return
	if not body is Player:
		return
	
	# Se buscan acá y no en _ready: el generador agrega los metadatos
	# de la sala DESPUÉS de instanciarla.
	boss_room = _find_boss_room()
	generator = get_tree().get_first_node_in_group("dungeon_generator")
	
	if boss_room == null:
		push_warning("BossRoomTrigger: no encontré la sala del jefe (meta 'boss_room') en los padres.")
		return
	if generator == null:
		push_warning("BossRoomTrigger: no hay ningún nodo en el grupo 'dungeon_generator'.")
		return
	
	print("PLAYER ENTRÓ A LA SALA DEL BOSS")
	state = State.FIGHTING
	
	# Deferred: dentro de body_entered no se pueden cambiar colisiones
	generator.call_deferred("lock_boss_room", boss_room)
	_connect_boss()


func _find_boss_room() -> Node2D:
	var node: Node = get_parent()
	while node != null:
		if node.has_meta("boss_room"):
			return node as Node2D
		node = node.get_parent()
	return null


func _connect_boss() -> void:
	var boss: Node = null
	for candidate in boss_room.find_children("*", "", true, false):
		if candidate.is_in_group(boss_group):
			boss = candidate
			break
	
	if boss == null:
		push_warning("BossRoomTrigger: no hay ningún nodo del grupo '%s' en la sala." % boss_group)
		return
	
	if boss.has_signal(defeated_signal):
		boss.connect(defeated_signal, _on_boss_defeated, CONNECT_ONE_SHOT)
	else:
		boss.tree_exiting.connect(_on_boss_removed.bind(boss), CONNECT_ONE_SHOT)


func _on_boss_removed(boss: Node) -> void:
	# Si se eliminó porque se limpió el nivel (no por morir), no cuenta como derrota
	if boss.is_queued_for_deletion():
		_on_boss_defeated()


func _on_boss_defeated() -> void:
	if state != State.FIGHTING:
		return
	state = State.CLEARED
	print("BOSS DERROTADO")
	
	if is_instance_valid(generator) and is_instance_valid(boss_room):
		generator.call_deferred("complete_boss_room", boss_room)
