class_name Room
extends RefCounted

var grid_position: Vector2i
var connections: Array[Room] = []
var room_type := "normal"
