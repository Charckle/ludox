extends Node

var continue_path := "user://continue_game.json"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func save_continue(game_state):
	var file = FileAccess.open(continue_path, FileAccess.WRITE)
	if file:
		var json_text = JSON.stringify(game_state, "\t")  # Pretty-printed with tabs
		file.store_string(json_text)
		file.close()
	else:
		push_error("Could not open config JSON file.")

func load_continue():
	var file = FileAccess.open(continue_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var parsed = JSON.parse_string(content)
		if typeof(parsed) == TYPE_DICTIONARY:
			return parsed
		else:
			push_error("Failed to parse config JSON as dictionary.")
	else:
		push_error("Could not open config JSON file.")
	

func check_continue_exists():
	if FileAccess.file_exists(continue_path):
		return true
	else:
		false

func delete_continue() -> void:
	if FileAccess.file_exists(continue_path):
		var err := DirAccess.remove_absolute(continue_path)
		if err != OK:
			push_error("Failed to delete %s (err %d)" % [continue_path, err])
