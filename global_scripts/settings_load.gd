extends Node

var config_path := "user://settings.json"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func create_config_if_not():
	if not FileAccess.file_exists(config_path):
		var default_file = FileAccess.open("res://default_data/settings.json", FileAccess.READ)
		var user_file = FileAccess.open(config_path, FileAccess.WRITE)
		user_file.store_string(default_file.get_as_text())

func save_settings():
	create_config_if_not()
	
	var file = FileAccess.open(config_path, FileAccess.WRITE)
	if file:
		var json_text = JSON.stringify(GlobalSet.settings, "\t")  # Pretty-printed with tabs
		file.store_string(json_text)
		file.close()
	else:
		push_error("Could not open config JSON file.")

func load_settings():
	create_config_if_not()
	
	var file = FileAccess.open(config_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var parsed = JSON.parse_string(content)
		if typeof(parsed) == TYPE_DICTIONARY:
			GlobalSet.settings = parsed
		else:
			push_error("Failed to parse config JSON as dictionary.")
	else:
		push_error("Could not open config JSON file.")
	
