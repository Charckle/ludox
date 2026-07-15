extends RefCounted

# Gallic Wars campaign. All battles use XXI rules, human = player 2 (bottom).
# map_position values are placeholder panel-local coords; nudge them once you
# can see the dots on the map.

const RULES_XXI := 2
const EASY := 0
const NORMAL := 1
const HARD := 2


static func build() -> CampaignData:
	var c := CampaignData.new()
	c.id = "gallic_wars"
	c.title = "Gallic Campaign"
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
		ai: int, rows: Array) -> BattleData:
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
	return b


static func _bibracte() -> BattleData:
	return _battle(
		"bibracte",
		"Mission 1 - Battle of Bibracte (58 BCE)",
		"The Helvetii tribes are marching through Gaul, threatening Roman allies. "
		+ "Caesar has intercepted them near Bibracte. Their warriors are massed and ready — "
		+ "stop their advance before they push deeper into Roman territory.",
		Vector2(90, 60),
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
		Vector2(150, 80),
		NORMAL,
		[
			"e e e e e e e e",
			". . . E . . . .",
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
		Vector2(205, 60),
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
		Vector2(115, 115),
		HARD,
		[
			". . . . . . . . . . . . .",
			". . . . . . . . . e e e e",
			". . . . . . . . . . e E .",
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
		Vector2(160, 120),
		HARD,
		[
			". . . . e e e e . . . . .",
			". . . . e E e e . . . . .",
			". . . . e e e e . . . . .",
			". . . . . . . . . . . . .",
			"d . . . . . . . . . . . d",
			". d . . . . . . . . . d .",
			". . d . . . . . . . d . .",
			". . . d d D d d d . . . .",
		]
	)


static func _uxellodunum() -> BattleData:
	return _battle(
		"uxellodunum",
		"Mission 6 - Battle of Uxellodunum (51 BCE)",
		"Vercingetorix has surrendered, but one fortress still flies the Gallic banner. "
		+ "The defenders of Uxellodunum hold the high ground with a secure water supply. "
		+ "Caesar will not leave Gaul until the last resistance is broken.",
		Vector2(105, 150),
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
