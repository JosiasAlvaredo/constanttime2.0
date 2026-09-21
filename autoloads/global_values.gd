extends Node

var start_door=""

var gravity=980
var is_dialogue_active=false
var time=60

var bodies_parts={"torso":null,
				"right_arm":null,
				"left_arm":null,
				"legs":null,
				"right_hand":null,
				"left_hand":null}

var has_met_npc = false

var hechizo=false

var Left_hand={"name":"","durability":""}
var Right_hand={"name":"","durability":""}

enum Effects {fire,poison,slowly}

enum BodyParts { torso,left_arm,right_arm,legs,right_hand,left_hand }
