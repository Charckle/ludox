extends Resource
class_name BattleData

# Unique id, used to track wins in CampaignProgress.
@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
# Shown after the player wins this campaign battle. Empty = generic victory text.
@export_multiline var victory_text: String = ""

# Where the dot sits on the campaign map, as UV coords on the map texture (0-1).
@export var map_position: Vector2 = Vector2.ZERO

# City.Rules index: 0 = BASIC, 1 = BASIC_PLUS, 2 = XXI
@export var rules: int = 2
# City.Ai_lvl index: 0 = EASY, 1 = NORMAL, 2 = HARD, 3 = CAESAR
@export var ai_lvl: int = 1

# Board dimensions. Height must be 8; width is 8 or 12.
@export var city_size: Vector2i = Vector2i(8, 8)

# Each entry: { "pos": Vector2i, "player": int, "dux": bool, "faction": String? }
# player 1 = AI (top), player 2 = human (bottom). Optional faction overrides the side look.
@export var pawns: Array = []

# Optional opener played once when Epic mode is on, then the normal battle playlist.
@export var epic_track: String = ""

# Optional per-battle pawn looks. When set, overrides CampaignData.cosmetics.
# player 1 = AI (top), player 2 = human (bottom).
# Each value: { "faction": String, "color": String }
@export var cosmetics: Dictionary = {}
