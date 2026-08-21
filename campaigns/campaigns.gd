extends Node

# Registry of all solo campaigns.
# To add a new campaign: create a definition script with a static build()
# returning a CampaignData, then add one preload(...).build() line below.

var all: Array = []


func _ready() -> void:
	all = [
		preload("res://campaigns/definitions/gallic_wars.gd").build(),
	]


func get_by_id(id: String) -> CampaignData:
	for c in all:
		if c.id == id:
			return c
	return null
