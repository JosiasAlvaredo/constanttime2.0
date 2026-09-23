class_name LevelData
extends Resource

## Toda la configuración de UN nivel/bioma.
## Crea un archivo .tres por nivel (Clic derecho > Nuevo recurso > LevelData).

@export var level_name: String = "Cueva"

@export_group("Cantidades")
@export var modules_to_generate: int = 10
@export var treasure_room_count: int = 1

@export_group("Módulos")
@export var start_module: PackedScene
@export var room_modules: Array[PackedScene] = []
@export var corridor_h_modules: Array[PackedScene] = []
@export var corridor_v_modules: Array[PackedScene] = []
@export var treasure_modules: Array[PackedScene] = []
@export var boss_modules: Array[PackedScene] = []

@export_group("Fondo")
@export var background_tileset: TileSet
@export var background_source_id: int = 0
@export var background_tiles: Array[Vector2i] = [Vector2i.ZERO]
@export_range(0.0, 1.0) var background_variant_chance: float = 0.15
@export var background_margin_tiles: int = 10
