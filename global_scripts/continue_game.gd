extends Node

var continue_path := "user://continue_game.json"


func save_continue(game_state):
	var file = FileAccess.open(continue_path, FileAccess.WRITE)
	if file:
		var json_text = JSON.stringify(game_state, "\t")  # Pretty-printed with tabs
		file.store_string(json_text)
		file.close()
	else:
		push_error("Could not open config JSON file.")


func load_continue():
	var parsed = _read_continue()
	if parsed == null:
		push_error("Could not open or parse continue save.")
	return parsed


func _read_continue():
	if not FileAccess.file_exists(continue_path):
		return null
	var file = FileAccess.open(continue_path, FileAccess.READ)
	if file == null:
		return null
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return null


func check_continue_exists() -> bool:
	return FileAccess.file_exists(continue_path)


func delete_continue() -> void:
	if FileAccess.file_exists(continue_path):
		var err := DirAccess.remove_absolute(continue_path)
		if err != OK:
			push_error("Failed to delete %s (err %d)" % [continue_path, err])


func is_continue_for(camp_id: String, battle_id: String) -> bool:
	var state = _read_continue()
	if typeof(state) != TYPE_DICTIONARY:
		return false
	return str(state.get("campaign_id", "")) == camp_id \
		and str(state.get("battle_id", "")) == battle_id


# Restores GlobalSet so the next battle scene load resumes this save.
# Returns false if the file is missing or points at an unknown campaign battle.
func apply_continue_to_global() -> bool:
	var state = _read_continue()
	if typeof(state) != TYPE_DICTIONARY:
		return false
	var camp_id := str(state.get("campaign_id", ""))
	var battle_id := str(state.get("battle_id", ""))
	if camp_id == "" or battle_id == "":
		GlobalSet.load_saved_continue = true
		GlobalSet.skip_epic_opener = true
		GlobalSet.current_battle = null
		GlobalSet.current_campaign_id = ""
		GlobalSet.match_cosmetics = null
		return true
	var battle = Campaigns.get_battle(camp_id, battle_id)
	if battle == null:
		push_warning("Continue save refers to missing battle %s/%s" % [camp_id, battle_id])
		delete_continue()
		return false
	GlobalSet.load_saved_continue = true
	GlobalSet.skip_epic_opener = true
	GlobalSet.current_campaign_id = camp_id
	GlobalSet.current_battle = battle
	GlobalSet.match_cosmetics = null
	return true
