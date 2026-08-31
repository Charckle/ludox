extends RefCounted

# Caesar's Civil War. XXI rules, human = player 2 (bottom).
# Default: you are Caesar (roman red); e/E are Pompeians (roman blue).
# Dyrrhachium: you are Pompey (roman blue).
# map_position is a UV on map_sout_europe.png. Spanish sites (Ilerda / Munda)
# are nudged apart at this zoom.
#
# LETTERS:
#   e/E  enemy default (Pompeian blue, or Caesar red at Dyrrhachium)
#   d/D  you default (Caesar red, or Pompeian blue at Dyrrhachium)
#   f/F  Gallic cavalry with Caesar (Pharsalus)
#   o/O  Pontus (Zela)
#   n/N  Numidian (Thapsus)

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
	"F": {"player": 2, "dux": true, "faction": "gaul"},
	"f": {"player": 2, "dux": false, "faction": "gaul"},
	"O": {"player": 1, "dux": true, "faction": "pontus"},
	"o": {"player": 1, "dux": false, "faction": "pontus"},
	"N": {"player": 1, "dux": true, "faction": "numidian"},
	"n": {"player": 1, "dux": false, "faction": "numidian"},
}

const CAESAR := {
	"1": {"faction": "roman", "color": "blue"},
	"2": {"faction": "roman", "color": "red"},
}
const POMPEY := {
	"1": {"faction": "roman", "color": "red"},
	"2": {"faction": "roman", "color": "blue"},
}


static func build() -> CampaignData:
	var c := CampaignData.new()
	c.id = "civil_war"
	c.title = "Civil War"
	c.map_texture = preload("res://sprites/images/map_sout_europe.png")
	c.cosmetics = CAESAR
	c.battles = [
		_ilerda(),
		_dyrrhachium(),
		_pharsalus(),
		_zela(),
		_thapsus(),
		_munda(),
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


static func _ilerda() -> BattleData:
	return _with_victory(_battle(
		"ilerda",
		"Mission 1 - Battle of Ilerda (49 BCE)",
		"The die is cast. Pompey has fled Italy; his lieutenants Afranius and Petreius "
		+ "hold the Ebro at Ilerda. Caesar's army cuts them off from the river and forces "
		+ "the hills — Spain must answer to him.",
		Vector2(0.24, 0.34),  # Lleida / Ebro, NE Hispania
		NORMAL,
		[
			"e e e e e e e e",
			". . E . . . . .",
			". . . . . . . .",
			". d . . e e . .",
			". d . . . . . .",
			". . . . . . . .",
			". . . D . . . .",
			"d . d d d d d d",
		],
		"res://audio/music/epic/The Rubicon.ogg"
	), "The Ebro is Caesar's. Pompey's Spanish army is cut off and forced to terms — Spain answers to him.")


static func _dyrrhachium() -> BattleData:
	return _with_victory(_battle(
		"dyrrhachium",
		"Mission 2 - Battle of Dyrrhachium (48 BCE)",
		"Caesar has followed Pompey to Epirus and thrown siege lines around the camp by "
		+ "the sea. Supplies are short, the works are thin. Pompey massed inside is about "
		+ "to break out — if the ring shatters, the campaign in Greece turns on this morning.",
		Vector2(0.49, 0.35),  # Durrës, Adriatic
		NORMAL,
		[
			". . e . . e . .",
			". e e E . e . e",
			"e e . . . . . e",
			"e . . d d d . .",
			". . . . . . . .",
			". . . . . . . .",
			"d . . D . . . d",
			"d d . . . d d d",
		],
		"",
		POMPEY
	), "The siege lines shatter. Caesar is thrown back from the sea, and Greece is still Pompey's.")


static func _pharsalus() -> BattleData:
	return _with_victory(_battle(
		"pharsalus",
		"Mission 3 - Battle of Pharsalus (48 BCE)",
		"Pompey has the numbers and the cavalry. Caesar's right is thin; Gallic horse "
		+ "hold it. If the Pompeian wing rolls the line up, the civil war is over. The "
		+ "two armies cross the plain of Pharsalus to decide the Republic.",
		Vector2(0.58, 0.41),  # Thessaly
		HARD,
		[
			"e . . . e e e e e . . . e",
			". e e e . . E . . e e e .",
			". . . . . . . . . . . . .",
			". e e e . . . . . . . . .",
			". . d d . . . e . e e e .",
			". . . d d . . . . . . . .",
			". . d . d . D . d d . f f",
			"d d . . . d d d d d d . f",
		],
		"res://audio/music/epic/Cross the Plain, Caesar.ogg"
	), "The field is Caesar's. Pompey flees east. The Republic has a master, whether it will or no.")


static func _zela() -> BattleData:
	return _with_victory(_battle(
		"zela",
		"Mission 4 - Battle of Zela (47 BCE)",
		"Pharnaces of Pontus has come down from the hills to test a tired Caesarian army. "
		+ "There is no time for a camp. The armies form, charge, and it is over before noon.",
		Vector2(0.80, 0.30),  # Zile, Pontus
		HARD,
		[
			"o o . . . . . o",
			". . O . . . . .",
			". . . . . . . .",
			"o o . . o o . o",
			". . o . . . o .",
			". . . . d d . .",
			". . . D . . . .",
			"d d d . . d d d",
		]
	), "It is over before noon. Pontus is finished. Veni, vidi, vici.")


static func _thapsus() -> BattleData:
	return _with_victory(_battle(
		"thapsus",
		"Mission 5 - Battle of Thapsus (46 BCE)",
		"Metellus Scipio waits in Africa with King Juba's Numidians and a screen of "
		+ "elephants. The Pompeian cause has one more army. Caesar meets them on the coast "
		+ "before they can make this province a second Spain.",
		Vector2(0.40, 0.58),  # eastern Tunisia, south of Carthage
		CEASAR,
		[
			". . . . . . . e e e n n n",
			". . . e . E . e . n . . .",
			"e . e e e . . . . . . d .",
			". n . . . . . . . . d . .",
			"n . . . . . . . . d . . .",
			". . . . . . D . d . . . .",
			". . d d d d . . . . . . .",
			"d d d . . . . . . . . . .",
		]
	), "The elephants turn on their own. Scipio's African army is destroyed, and the Pompeian cause has no province left.")


static func _munda() -> BattleData:
	return _with_victory(_battle(
		"munda",
		"Mission 6 - Battle of Munda (45 BCE)",
		"Gnaeus Pompey holds the high ground in Spain with the last of his father's men. "
		+ "Caesar later called this the hardest fight of his life. When the hill falls, "
		+ "the civil war is finished.",
		Vector2(0.13, 0.50),  # southern Hispania (Osuna / Monda)
		CEASAR,
		[
			". . . . . . . . . . . . .",
			"e e e e e . E . e e e e e",
			". . . . . . . . e e e e e",
			". e . . e e . . . d d d e",
			"e . e e . . . . D d . . .",
			". . d . e . . . . . . . .",
			"d . d d d . . . d d d . d",
			". . . . . d d . . . . . .",
		],
		"res://audio/music/epic/Blood Upon the Sand (Steel Legion Mix) (Edit).ogg"
	), "The hill is taken. Caesar later called this the hardest fight of his life — and the last.")
