extends RefCounted

# Punic Wars. XXI rules, human = player 2 (bottom).
# Default: you are Rome. Trebia / Trasimene / Cannae: you are Carthage.
# map_position is a UV on punicmap.png. Sicily sites (Agrigentum / Ecnomus)
# and the Italian cluster are nudged apart at this zoom.
#
# LETTERS:
#   e/E  enemy default (Carthage, or Rome on Trebia / Trasimene / Cannae)
#   d/D  you default (Rome, or Carthage on those three)
#   u/U  Gauls with the enemy (Hasdrubal at the Metaurus)
#   f/F  Gauls with you (Hannibal at Trebia / Trasimene / Cannae)
#   n/N  Numidians with you (Hannibal at Trebia / Trasimene / Cannae; Masinissa at Zama)

const RULES_XXI := 2
const EASY := 0
const NORMAL := 1
const HARD := 2
const CEASAR := 3

const LETTERS := {
	"E": {"player": 1, "dux": true},
	"e": {"player": 1, "dux": false},
	"D": {"player": 2, "dux": true},
	"d": {"player": 2, "dux": false},
	"U": {"player": 1, "dux": true, "faction": "gaul"},
	"u": {"player": 1, "dux": false, "faction": "gaul"},
	"F": {"player": 2, "dux": true, "faction": "gaul"},
	"f": {"player": 2, "dux": false, "faction": "gaul"},
	"N": {"player": 2, "dux": true, "faction": "numidian"},
	"n": {"player": 2, "dux": false, "faction": "numidian"},
}

const ROME := {
	"1": {"faction": "carthage", "color": "yellow"},
	"2": {"faction": "roman", "color": "red"},
}
const CARTHAGE := {
	"1": {"faction": "roman", "color": "red"},
	"2": {"faction": "carthage", "color": "yellow"},
}


static func build() -> CampaignData:
	var c := CampaignData.new()
	c.id = "punic_wars"
	c.title = "Punic Wars"
	c.map_texture = preload("res://sprites/images/punicmap.png")
	c.cosmetics = ROME
	c.battles = [
		_agrigentum(),
		_ecnomus(),
		_trebia(),
		_trasimene(),
		_cannae(),
		_metaurus(),
		_zama(),
	]
	return c


static func _battle(id: String, title: String, desc: String, map_pos: Vector2,
		ai: int, rows: Array, epic_track: String = "",
		cosmetics: Dictionary = {}) -> BattleData:
	var parsed := AsciiLayout.parse(rows, LETTERS)
	var b := BattleData.new()
	b.id = id
	b.title = title
	b.description = desc
	b.map_position = map_pos
	b.rules = RULES_XXI
	b.ai_lvl = ai
	b.city_size = parsed["size"]
	b.pawns = parsed["pawns"]
	b.epic_track = epic_track
	b.cosmetics = cosmetics
	return b


static func _with_victory(b: BattleData, text: String) -> BattleData:
	b.victory_text = text
	return b


static func _agrigentum() -> BattleData:
	return _with_victory(_battle(
		"agrigentum",
		"Mission 1 - Siege of Agrigentum (262 BCE)",
		"Rome has crossed to Sicily. The Carthaginian garrison holds Agrigentum, the richest "
		+ "city on the island. A Roman army sits down before the walls to starve them out — "
		+ "the Republic's first real trial against Carthage on land.",
		Vector2(0.46, 0.54),  # Agrigento, southern Sicily
		EASY,
		[
			"e e e e e e e e",
			". . E . . . . .",
			". . . . . . . .",
			". . . . . . . .",
			". . . . . . . .",
			". . . . . . . .",
			". . . D . . . .",
			"d d d d d d d d",
		]
	), "Agrigentum is taken. Sicily's richest city flies Roman colors, and the war with Carthage has truly begun.")


static func _ecnomus() -> BattleData:
	return _with_victory(_battle(
		"ecnomus",
		"Mission 2 - Battle of Cape Ecnomus (256 BCE)",
		"The Senate has voted to invade Africa. Off southern Sicily the two fleets meet — "
		+ "hundreds of hulls, the largest sea fight the world has seen. The Roman wedge "
		+ "drives at the Carthaginian center to break the envelopment and open the road to Africa.",
		Vector2(0.53, 0.59),  # south coast of Sicily, near Licata
		NORMAL,
		[
			". e . e e e e e . . e .",
			"e . e e . E . e . e . e",
			". . . . . . . . . . . .",
			". . . . . . . . . . . .",
			". . . . e e e . . . . .",
			". . . . . d d . . . . .",
			". . . . d . D d . . . .",
			". d d d . . . . d d . .",
		],
		"res://audio/music/epic/The Battle of the Black Sea.ogg"
	), "The sea is Rome's. Hundreds of hulls litter the water, and the road to Africa lies open.")


static func _trebia() -> BattleData:
	return _with_victory(_battle(
		"trebia",
		"Mission 3 - Battle of the Trebia (218 BCE)",
		"Hannibal has come over the Alps with Gauls at his back. Numidian horse draw "
		+ "Sempronius across the icy Trebia; the Punic center looks open. Mago's Celts "
		+ "wait in a ravine on the Roman flank. When the lines close, the trap is sprung.",
		Vector2(0.47, 0.16),  # Po valley, north Italy
		NORMAL,
		[
			"e e e e e e e e",
			". e . E . e . .",
			". . . . e . . .",
			"f . e e e e . f",
			"f . . e e . . f",
			"n . . . . . . n",
			". . . D . . . .",
			"d d d d d d d d",
		],
		"res://audio/music/epic/Barca On The Alps.ogg",
		CARTHAGE
	), "The trap closes on the icy river. Sempronius is routed, and Hannibal has his first great victory in Italy.")


static func _trasimene() -> BattleData:
	return _with_victory(_battle(
		"trasimene",
		"Mission 4 - Battle of Lake Trasimene (217 BCE)",
		"Flaminius marches along the lake in the morning fog. Maharbal's Numidians seal "
		+ "the rear; Hannibal's Africans hold the road ahead; Gallic warbands wait on the "
		+ "hills above. The defile is a trap: the Roman column is caught with water at its back.",
		Vector2(0.46, 0.31),  # Lake Trasimene, Umbria
		HARD,
		[
			". . . . e e . . . . . . d",
			"n . . e e e . E e e . . d",
			"n . e . e . e . e . . . d",
			". . . e . e . e . . . D d",
			"n . . . e . . . . . . . d",
			"f . . . . . . . . . . . d",
			". . . . . . . . . . . . d",
			"n . . . f f . d d . . . d",
		],
		"",
		CARTHAGE
	), "The fog lifts on a slaughter. Flaminius is dead, and the lake is a grave for Rome.")


static func _cannae() -> BattleData:
	return _with_victory(_battle(
		"cannae",
		"Mission 5 - Battle of Cannae (216 BCE)",
		"Two consular armies have cornered Hannibal on the Aufidus. His Gauls sag in the "
		+ "center; the African infantry wait on the left, Maharbal's Numidians on the right. "
		+ "If the Roman line drives too deep, the crescent closes and the largest army Rome "
		+ "has ever fielded is surrounded.",
		Vector2(0.61, 0.43),  # Apulia, the heel of Italy
		CEASAR,
		[
			"n n . . . . . . . . . n n",
			". . e e . . E . . e e . .",
			". . e e . e . . . e e . .",
			"d . . e e e e e e e . . d",
			"d . . . . e e e . . . . d",
			". d d . . . . . . . d d .",
			". . . d . f f f . d . . .",
			". . . . . . D . . . . . .",
		],
		"res://audio/music/epic/Cannae Ring.ogg",
		CARTHAGE
	), "The crescent closes. Rome's largest army is no more. Hannibal has his masterpiece.")


static func _metaurus() -> BattleData:
	return _with_victory(_battle(
		"metaurus",
		"Mission 6 - Battle of the Metaurus (207 BCE)",
		"Hasdrubal has crossed from Spain to join his brother. If the two armies meet, "
		+ "Italy falls. A Roman consular army intercepts him on the Metaurus before Hannibal "
		+ "knows he has come — the last Gallic host Carthage will field in Italy.",
		Vector2(0.57, 0.25),  # Metauro, Marche / Adriatic Italy
		HARD,
		[
			". . e e e e e e . . . u u",
			". . e e e . E . e e u . .",
			". . . . . . . . . . . . .",
			"u u . . . e . . . . . . .",
			". . . . . . . . u e e . .",
			". d . d . . . . . . . . .",
			". . d . . . D . d d d d .",
			". . . . d d . . . . . . d",
		]
	), "Hasdrubal never reaches his brother. The two Carthaginian armies will not meet in Italy.")


static func _zama() -> BattleData:
	return _with_victory(_battle(
		"zama",
		"Mission 7 - Battle of Zama (202 BCE)",
		"Scipio has carried the war to Africa. Hannibal is home, the Gauls are gone, "
		+ "and Masinissa's Numidians ride on the Roman right. The elephants will come "
		+ "first. On the plain of Zama the two armies meet: Rome did not break at Cannae, "
		+ "and the war will end here.",
		Vector2(0.36, 0.78),  # inland Numidia, SW of Carthage
		CEASAR,
		[
			"e e . e e e e e e e . e e",
			"e e e e e e e e e e e e e",
			". . e . . . E . . . e . .",
			". . . . . . . . . . . . .",
			". . . e e e . . . . e e .",
			". . . . . . . D . . . . .",
			"n n d . . d d d d . . n n",
			"n n d d d . . . . d d n n",
		],
		"res://audio/music/epic/Rome Never Broke.ogg"
	), "Hannibal is beaten on African soil. Carthage will treat for peace. The war is over.")
