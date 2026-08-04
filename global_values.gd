extends Node

var start_door=""

var gravity=980
var is_dialogue_active=false
var time=60

var bodies_parts={"torso":"res://characters/player/Body_parts/torsos/none.tscn",
				"right_arm":"res://characters/player/Body_parts/arms/stick_arm.tscn",
				"left_arm":"res://characters/player/Body_parts/arms/stick_arm.tscn",
				"legs":"res://characters/player/Body_parts/legs/stick_legs.tscn"}

var has_met_npc = false

var hechizo=false

var Left_hand={"name":"","durability":""}
var Right_hand={"name":"","durability":""}

#Bosque
var Bosque={
	"LLave_del_bosque":true,
	"Puerta_del_bosque":false
}
