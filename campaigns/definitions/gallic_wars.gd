extends RefCounted

# Gallic Wars campaign. All battles use XXI rules, human = player 2 (bottom).
# map_position is a UV on map_gaul_c.png. Burgundy sites (Alesia / Bibracte)
# are nudged apart so the dots do not overlap at this zoom.
# T/t = German (Ariovistus at Vosges).

const RULES_XXI := 2
const EASY := 0
const NORMAL := 1
const HARD := 2


static func build() -> CampaignData:
	var c := CampaignData.new()
	c.id = "gallic_wars"
	c.title = "Gallic Campaign"
	c.map_texture = preload("res://sprites/images/map_gaul_c.png")
	c.cosmetics = {
		"1": {"faction": "gaul", "color": "green"},
		"2": {"faction": "roman", "color": "red"},
	}
	c.battles = [
		_bibracte(),
		_vosges(),
		_sabis(),
		_avaricum(),
		_alesia(),
		_uxellodunum(),
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


static func _bibracte() -> BattleData:
	return _battle(
		"bibracte",
		"Mission 1 - Battle of Bibracte (58 BCE)",
		"The Helvetii tribes are marching through Gaul, threatening Roman allies. "
		+ "Caesar has intercepted them near Bibracte. Their warriors are massed and ready — "
		+ "stop their advance before they push deeper into Roman territory.",
		Vector2(0.60, 0.54),  # Mont Beuvray (Morvan), south of Alesia
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
	)


static func _vosges() -> BattleData:
	return _battle(
		"vosges",
		"Mission 2 - Battle of Vosges (58 BCE)",
		"Ariovistus, a Germanic warlord, holds land in eastern Gaul and terrorizes local tribes. "
		+ "They have appealed to Rome for protection. Caesar marches to confront Ariovistus "
		+ "before his influence spreads across the region.",
		Vector2(0.75, 0.36),  # Alsace / Rhine (Ochsenfeld)
		NORMAL,
		[
			"t t t t t t t t",
			"t . . T . . . t",
			". . . . . . . .",
			". . . . . . . .",
			". . . . . . . .",
			". . . . . . . .",
			". . . D . . . .",
			"d d d d d d d d",
		]
	)


static func _sabis() -> BattleData:
	return _battle(
		"sabis",
		"Mission 3 - Battle of the Sabis (57 BCE)",
		"Caesar's legions are crossing the Sabis when the Nervii launch a surprise attack "
		+ "from the woods. Your column is strung out and the enemy hits from multiple sides. "
		+ "Rally your men — this ambush could destroy the army.",
		Vector2(0.57, 0.21),  # Nervii / Selle, northern Gaul
		NORMAL,
		[
			". e . . . . e .",
			"e . E . . . . e",
			". . . . . . . .",
			". . . . . . . .",
			". . . e e e . .",
			". . . . . . . .",
			". d d D d d . .",
			". . d . . d . .",
		]
	)


static func _avaricum() -> BattleData:
	return _battle(
		"avaricum",
		"Mission 4 - Siege of Avaricum (52 BCE)",
		"Gaul has risen under Vercingetorix. The fortified town of Avaricum shelters a large "
		+ "hostile force behind strong walls. Caesar orders a siege. Break their defense "
		+ "before the defenders can hold out indefinitely.",
		Vector2(0.44, 0.47),  # Bourges (Berry), west of Bibracte
		HARD,
		[
			". . . . . e e e . . . . .",
			"e e e e . . . e . e e e e",
			". . . . . E . . . . e e .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . . . . . d d d d d d .",
			"d d d d d d D . . . . d d",
		]
	)


static func _alesia() -> BattleData:
	return _battle(
		"alesia",
		"Mission 5 - Battle of Alesia (52 BCE)",
		"Vercingetorix has withdrawn to the hill-fort of Alesia with his army. Caesar's "
		+ "legions encircle the plateau, but a great Gallic relief force is marching to "
		+ "break the siege. Hold against attacks from inside and outside the ring.",
		Vector2(0.63, 0.39),  # Alise-Sainte-Reine, north of Bibracte
		HARD,
		[
			"e e e e e e e e e e e e e",
			". . . . . . E . . . . . .",
			". . . . . . . . . . . . .",
			"d d d d d d . d d d d d d",
			". . d d . . D . . d d . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			"e e e e e e e e e e e e e",
		],
		"res://audio/music/epic/Rome's route.mp3"
	)


static func _uxellodunum() -> BattleData:
	return _battle(
		"uxellodunum",
		"Mission 6 - Battle of Uxellodunum (51 BCE)",
		"Vercingetorix has surrendered, but one fortress still flies the Gallic banner. "
		+ "The defenders of Uxellodunum hold the high ground with a secure water supply. "
		+ "Caesar will not leave Gaul until the last resistance is broken.",
		Vector2(0.43, 0.66),  # Puy d'Issolud (Lot), southwest Gaul
		HARD,
		[
			". . . . . . . .",
			". . e e E e e .",
			". . e e e e e .",
			". . . . . . . .",
			". . . . . . . .",
			". d . . . . . d",
			". . d d D d d .",
			"d d . . . . d d",
		]
	)
