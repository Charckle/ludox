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
		else:
			push_error("Failed to parse config JSON as dictionary.")
	else:
		push_error("Could not open config JSON file.")
	


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
