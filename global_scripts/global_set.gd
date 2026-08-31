extends Node

enum Rules {
	BASIC,
	BASIC_PLUS,
	XXI
}

var load_saved_continue = false
# Skip the campaign epic opener (Alesia, etc.) when resuming a continue save.
var skip_epic_opener = false

# Set when launching a solo campaign battle; null for normal/multiplayer games.
var current_battle = null
var current_campaign_id = ""
# Set when returning from a campaign battle so the menu reopens that campaign.
var pending_campaign_id := ""


func return_to_campaign_menu() -> void:
	pending_campaign_id = str(current_campaign_id)
	current_battle = null
	current_campaign_id = ""
	match_cosmetics = null

# Resolved per-match pawn looks: {"1": {"faction","color"}, "2": {...}}
# Kept across rematch; cleared when starting a fresh local/campaign game.
var match_cosmetics = null

#var game_rules = Rules.XXI # 0: basic, 1: basic plus
#var game_type = 1 # 0: player v player, 1: player v AI
#var ai_lvl = 0


var settings



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SettingsLoad.load_settings()
