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
		default_file = add_gernerated_name_to_default_file(default_file)
		var user_file = FileAccess.open(config_path, FileAccess.WRITE)
		user_file.store_string(default_file)

func save_settings():
	create_config_if_not()
	
	var file = FileAccess.open(config_path, FileAccess.WRITE)
	if file:
		var json_text = JSON.stringify(GlobalSet.settings, "\t")  # Pretty-printed with tabs
		file.store_string(json_text)
		file.close()
	else:
		push_error("Could not open config JSON file.")

func add_gernerated_name_to_default_file(default_file):
	var json_text = default_file.get_as_text()
	var data = JSON.parse_string(json_text)
	
	data["multiplayer"]["username"] = get_random_roman_name()
	
	return JSON.stringify(data, "\t")
	
func load_settings():
	create_config_if_not()
	
	var file = FileAccess.open(config_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var parsed = JSON.parse_string(content)
		if typeof(parsed) == TYPE_DICTIONARY:
			GlobalSet.settings = parsed
			_merge_missing_defaults()
		else:
			push_error("Failed to parse config JSON as dictionary.")
	else:
		push_error("Could not open config JSON file.")


func _default_settings_dict() -> Dictionary:
	var default_file = FileAccess.open("res://default_data/settings.json", FileAccess.READ)
	if default_file == null:
		return {}
	var parsed = JSON.parse_string(default_file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}


func _merge_missing_defaults() -> void:
	var defaults := _default_settings_dict()
	if defaults.is_empty():
		return
	var changed := _merge_dict(GlobalSet.settings, defaults)
	# Existing installs saved you=blue / opponent=red; flip to the new defaults.
	if _swap_legacy_default_colors():
		changed = true
	if changed:
		save_settings()


func _swap_legacy_default_colors() -> bool:
	if not GlobalSet.settings.has("cosmetics"):
		return false
	var cos: Dictionary = GlobalSet.settings["cosmetics"]
	if typeof(cos) != TYPE_DICTIONARY:
		return false
	var you: Dictionary = cos.get("you", {})
	var opp: Dictionary = cos.get("opponent", {})
	if str(you.get("color", "")) == "blue" and str(opp.get("color", "")) == "red":
		you["color"] = "red"
		opp["color"] = "blue"
		cos["you"] = you
		cos["opponent"] = opp
		return true
	return false


func _merge_dict(target: Dictionary, defaults: Dictionary) -> bool:
	var changed := false
	for key in defaults.keys():
		if not target.has(key):
			target[key] = defaults[key]
			changed = true
		elif typeof(defaults[key]) == TYPE_DICTIONARY and typeof(target[key]) == TYPE_DICTIONARY:
			if _merge_dict(target[key], defaults[key]):
				changed = true
	return changed



var praenomina = [
	"Aulus","Decimus","Gaius","Gnaeus","Lucius","Marcus","Publius","Quintus",
	"Servius","Sextus","Spurius","Titus","Tiberius","Numerius","Manius",
	"Aemilius","Flavius","Appius","Caeso","Faustus","Hostus","Mamercus",
	"Opiter","Postumus","Proculus","Vibius","Volusus","Hortensius","Plautius",
	"Sergius","Vitus","Silvanus","Remus","Romulus"
]

var nomina = [
	"Aemilius","Antonius","Aurelius","Cassius","Claudius","Cornelius","Domitius",
	"Fabius","Flavius","Julius","Junius","Licinius","Livius","Marcius","Octavius",
	"Pompeius","Sergius","Tarquinius","Valerius","Vergilius","Calpurnius","Tullius",
	"Fabinius","Plautius","Hostilius","Manlius","Horatius","Vipsanius","Petronius",
	"Proculeius","Lucretius","Trebonius","Atilius","Aquilius","Caecilius","Sulpicius",
	"Oppius","Papinius","Vitellius","Helvius"
]

var cognomina = [
	"Agrippa","Brutus","Cato","Cicero","Crispus","Drusus","Gallus","Gracchus",
	"Longinus","Magnus","Maximus","Nero","Paulus","Rufus","Scaurus","Scipio",
	"Severus","Silvanus","Varro","Varus","Albinus","Aquila","Balbus","Corvus",
	"Felis","Festus","Hadrianus","Julianus","Lepidus","Lupus","Marcellus","Otho",
	"Petronax","Regulus","Sabinus","Tacitus","Urbicus","Victor","Vitalis",
	"Zenodorus"
]

func get_random_roman_name() -> String:
	var pre = praenomina[randi() % praenomina.size()]
	var nom = nomina[randi() % nomina.size()]
	var cog = cognomina[randi() % cognomina.size()]
	return "%s %s %s" % [pre, nom, cog]
