extends Node

# Persists which campaign battles the player has won.
# Format: { "<campaign_id>": { "won": ["<battle_id>", ...] } }

var progress_path := "user://campaign_progress.json"
var data: Dictionary = {}


func _ready() -> void:
	_load()


func _load() -> void:
	if not FileAccess.file_exists(progress_path):
		data = {}
		return
	var file = FileAccess.open(progress_path, FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		data = parsed if typeof(parsed) == TYPE_DICTIONARY else {}
		file.close()
	else:
		data = {}


func _save() -> void:
	var file = FileAccess.open(progress_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
	else:
		push_error("Could not open campaign progress file.")


func is_won(camp_id: String, battle_id: String) -> bool:
	return data.has(camp_id) and battle_id in data[camp_id].get("won", [])


func mark_won(camp_id: String, battle_id: String) -> void:
	if not data.has(camp_id):
		data[camp_id] = {"won": []}
	if not data[camp_id].has("won"):
		data[camp_id]["won"] = []
	if battle_id not in data[camp_id]["won"]:
		data[camp_id]["won"].append(battle_id)
		_save()


# A battle is unlocked if it is the first, or the previous one is won.
func is_unlocked(camp: CampaignData, index: int) -> bool:
	if index <= 0:
		return true
	return is_won(camp.id, camp.battles[index - 1].id)
