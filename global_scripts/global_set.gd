extends Node

enum Rules {
	BASIC,
	BASIC_PLUS,
	XXI
}

var load_saved_continue = false

#var game_rules = Rules.XXI # 0: basic, 1: basic plus
#var game_type = 1 # 0: player v player, 1: player v AI
#var ai_lvl = 0


var settings



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SettingsLoad.load_settings()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
