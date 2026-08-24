extends Node

# Registry of all solo campaigns.
# To add a new campaign: create a definition script with a static build()
# returning a CampaignData, then add one preload(...).build() line below.

var all: Array = []


func _ready() -> void:
	all = [
		preload("res://campaigns/definitions/gallic_wars.gd").build(),
		preload("res://campaigns/definitions/greco_persian_wars.gd").build(),
		preload("res://campaigns/definitions/punic_wars.gd").build(),
		preload("res://campaigns/definitions/civil_war.gd").build(),
	]


func get_by_id(id: String) -> CampaignData:
	for c in all:
		if c.id == id:
			return c
	return null


func get_battle(camp_id: String, battle_id: String) -> BattleData:
	var camp := get_by_id(camp_id)
	if camp == null:
		return null
	for b in camp.battles:
		if b.id == battle_id:
			return b
	return null
