extends Node

enum Rules {
	BASIC,
	BASIC_PLUS,
	XXI
}

var game_rules = Rules.XXI # 0: basic, 1: basic plus
var game_type = 0 # 0: player v player, 1: player v AI
var ai_lvl = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
