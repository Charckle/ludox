extends Resource
class_name CampaignData

@export var id: String = ""
@export var title: String = ""

# Background drawn on the campaign panel while this campaign is selected.
@export var map_texture: Texture2D

# Ordered list of BattleData. A battle unlocks when the previous one is won.
@export var battles: Array = []

# Pawn looks for this campaign. player 1 = AI (top), player 2 = human (bottom).
# Each value: { "faction": String, "color": String }
@export var cosmetics: Dictionary = {}
