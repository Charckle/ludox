extends Resource
class_name CampaignData

@export var id: String = ""
@export var title: String = ""

# Ordered list of BattleData. A battle unlocks when the previous one is won.
@export var battles: Array = []
