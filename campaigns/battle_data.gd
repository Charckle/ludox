extends Resource
class_name BattleData

# Unique id, used to track wins in CampaignProgress.
@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""

# Where the dot sits on the campaign map (panel-local pixel coords).
@export var map_position: Vector2 = Vector2.ZERO

# City.Rules index: 0 = BASIC, 1 = BASIC_PLUS, 2 = XXI
@export var rules: int = 2
# City.Ai_lvl index: 0 = EASY, 1 = NORMAL, 2 = HARD
@export var ai_lvl: int = 1

# Board dimensions. Height must be 8; width is 8 or 12.
@export var city_size: Vector2i = Vector2i(8, 8)

# Each entry: { "pos": Vector2i, "player": int, "dux": bool }
# player 1 = AI (top, red), player 2 = human (bottom, blue)
@export var pawns: Array = []
