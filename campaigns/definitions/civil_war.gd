extends RefCounted

# Caesar's Civil War. All battles use XXI rules, human = player 2 (bottom).
# You are Caesar (roman red); e/E are Pompeians (roman blue).
# map_position is a UV on map_sout_europe.png. Spanish sites (Ilerda / Munda)
# are nudged apart at this zoom.
# f = your Gallic cavalry. o/O = Pontus. n = Numidian.

const RULES_XXI := 2
const EASY := 0
const NORMAL := 1
const HARD := 2


static func build() -> CampaignData:
	var c := CampaignData.new()
	c.id = "civil_war"
	c.title = "Civil War"
	c.map_texture = preload("res://sprites/images/map_sout_europe.png")
	c.cosmetics = {
		"1": {"faction": "roman", "color": "blue"},
		"2": {"faction": "roman", "color": "red"},
	}
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
		ai: int, rows: Array, epic_track: String = "") -> BattleData:
	var parsed := AsciiLayout.parse(rows)
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
	return b


static func _ilerda() -> BattleData:
	return _battle(
		"ilerda",
		"Mission 1 - Battle of Ilerda (49 BCE)",
		"The die is cast. Pompey has fled Italy; his lieutenants Afranius and Petreius "
		+ "hold the Ebro at Ilerda. Cut them off from the river, force the hills, and "
		+ "show Spain that the Republic now answers to Caesar.",
		Vector2(0.24, 0.34),  # Lleida / Ebro, NE Hispania
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
		],
		"res://audio/music/epic/The Rubicon.ogg"
	)


static func _dyrrhachium() -> BattleData:
	return _battle(
		"dyrrhachium",
		"Mission 2 - Battle of Dyrrhachium (48 BCE)",
		"You have followed Pompey to Epirus and thrown lines around his camp by the sea. "
		+ "Supplies are short, and he is about to break out. The works are thin. Hold "
		+ "the ring, or the campaign in Greece ends here.",
		Vector2(0.49, 0.35),  # Durrës, Adriatic
		NORMAL,
		[
			"e e e e e e e e",
			"e . . E . . . e",
			". . . . . . . .",
			". . . . . . . .",
			". . . e e e . .",
			". . . . . . . .",
			". d d D d d . .",
			". . d . . d . .",
		]
	)


static func _pharsalus() -> BattleData:
	return _battle(
		"pharsalus",
		"Mission 3 - Battle of Pharsalus (48 BCE)",
		"Pompey has the numbers and the cavalry. Your right is thin; Gallic horse must "
		+ "hold it. If his wing rolls you up, the civil war is over. Cross the plain "
		+ "and break the Senate's last army.",
		Vector2(0.58, 0.41),  # Thessaly
		HARD,
		[
			"e e e e e e e e e e e e e",
			". e e e . . E . . e e e .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . d d d . D . d d . f f",
			"d d d d d d d d d d d . f",
		],
		"res://audio/music/epic/Cross the Plain, Caesar.ogg"
	)


static func _zela() -> BattleData:
	return _battle(
		"zela",
		"Mission 4 - Battle of Zela (47 BCE)",
		"Pharnaces of Pontus has come down from the hills to test a tired army. "
		+ "There is no time for a camp. Form, charge, and be done before noon. "
		+ "I came, I saw, I conquered.",
		Vector2(0.80, 0.30),  # Zile, Pontus
		NORMAL,
		[
			"o o o o o o o o",
			". . O . . . . .",
			". . . . . . . .",
			". . . . . . . .",
			". . . . . . . .",
			". . . . . . . .",
			". . . D . . . .",
			"d d d d d d d d",
		]
	)


static func _thapsus() -> BattleData:
	return _battle(
		"thapsus",
		"Mission 5 - Battle of Thapsus (46 BCE)",
		"Metellus Scipio waits in Africa with King Juba's Numidians and a screen of "
		+ "elephants. The Pompeian cause has one more army. Break them on the coast "
		+ "before they can make this province a second Spain.",
		Vector2(0.40, 0.58),  # eastern Tunisia, south of Carthage
		HARD,
		[
			"n n e e e e e e e e n n n",
			". . e . . . E . . . n . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . d d d d . d d d d . .",
			"d d d d d d D . . . . d d",
		]
	)


static func _munda() -> BattleData:
	return _battle(
		"munda",
		"Mission 6 - Battle of Munda (45 BCE)",
		"Gnaeus Pompey holds the high ground in Spain with the last of his father's men. "
		+ "Caesar will later say this was the hardest fight of his life. Take the hill. "
		+ "When it falls, the civil war is finished.",
		Vector2(0.13, 0.50),  # southern Hispania (Osuna / Monda)
		HARD,
		[
			"e e e e e e . e e e e e e",
			"e e e e e . E . e e e e e",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			"d . d d d . D . d d d . d",
			"d d d d d d . d d d d d d",
		],
		"res://audio/music/epic/Blood Upon the Sand (Steel Legion Mix) (Edit).ogg"
	)
