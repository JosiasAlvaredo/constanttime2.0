class_name DungeonBackground
extends TileMapLayer
## Fondo de tiles de la mazmorra. Va como nodo hermano de "Dungeon", detrás de todo.
## Solo dibuja: sin colisión, navegación ni oclusión.

## Milisegundos por frame que se permite gastar rellenando (evita el freeze).
const FRAME_BUDGET_MSEC: float = 4.0

var _build_id: int = 0


func _ready() -> void:
	z_index = -100
	y_sort_enabled = false
	collision_enabled = false
	navigation_enabled = false
	occlusion_enabled = false
	rendering_quadrant_size = 32


## Rellena 'world_rect' (coordenadas globales, en píxeles) con el fondo del nivel.
func build(world_rect: Rect2, data: LevelData) -> void:
	_build_id += 1
	var my_id: int = _build_id
	clear()
	
	if data.background_tileset == null or data.background_tiles.is_empty():
		return
	tile_set = data.background_tileset
	
	var margin: Vector2i = Vector2i(data.background_margin_tiles, data.background_margin_tiles)
	var top_left: Vector2i = local_to_map(to_local(world_rect.position)) - margin
	var bottom_right: Vector2i = local_to_map(to_local(world_rect.end)) + margin
	
	var tiles: Array[Vector2i] = data.background_tiles
	var source_id: int = data.background_source_id
	var frame_start: int = Time.get_ticks_usec()
	
	for y in range(top_left.y, bottom_right.y + 1):
		for x in range(top_left.x, bottom_right.x + 1):
			var atlas: Vector2i = tiles[0]
			if tiles.size() > 1 and randf() < data.background_variant_chance:
				atlas = tiles[randi_range(1, tiles.size() - 1)]
			set_cell(Vector2i(x, y), source_id, atlas)
		
		# Si ya gastamos el presupuesto del frame, seguimos en el próximo
		if (Time.get_ticks_usec() - frame_start) > FRAME_BUDGET_MSEC * 1000.0:
			await get_tree().process_frame
			# Si mientras tanto se pidió otro fondo (cambio de nivel), abortar este
			if my_id != _build_id:
				return
			frame_start = Time.get_ticks_usec()
