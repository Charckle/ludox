extends RefCounted

# Punic Wars. All battles use XXI rules, human = player 2 (bottom), Rome.
# map_position is a UV on punicmap.png. Sicily sites (Agrigentum / Ecnomus)
# and the Italian cluster are nudged apart at this zoom.
# u/U = Gaul in Hannibal's army. e/E = Carthage (campaign default).

const RULES_XXI := 2
const EASY := 0
const NORMAL := 1
const HARD := 2


static func build() -> CampaignData:
	var c := CampaignData.new()
	c.id = "punic_wars"
	c.title = "Punic Wars"
	c.map_texture = preload("res://sprites/images/punicmap.png")
	c.cosmetics = {
		"1": {"faction": "carthage", "color": "yellow"},
		"2": {"faction": "roman", "color": "red"},
	}
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


static func _agrigentum() -> BattleData:
	return _battle(
		"agrigentum",
		"Mission 1 - Siege of Agrigentum (262 BCE)",
		"Rome has crossed to Sicily. The Carthaginian garrison holds Agrigentum, the richest "
		+ "city on the island. Sit down before the walls, starve them out, and prove that "
		+ "the Republic can fight Carthage on land.",
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
	)


static func _ecnomus() -> BattleData:
	return _battle(
		"ecnomus",
		"Mission 2 - Battle of Cape Ecnomus (256 BCE)",
		"The Senate has voted to invade Africa. Off southern Sicily the two fleets meet — "
		+ "hundreds of hulls, the largest sea fight the world has seen. Form the wedge, "
		+ "break their envelopment, and open the road to Carthage.",
		Vector2(0.53, 0.59),  # south coast of Sicily, near Licata
		NORMAL,
		[
			". e . . . . . . . . e .",
			"e . . e e E e e . . . e",
			". . . . . . . . . . . .",
			". . . . . . . . . . . .",
			". . . . e e e . . . . .",
			". . . . . d d . . . . .",
			". . . . d d D d . . . .",
			". . d d . . . . d d . .",
		],
		"res://audio/music/epic/The Battle of the Black Sea.ogg"
	)


static func _trebia() -> BattleData:
	return _battle(
		"trebia",
		"Mission 3 - Battle of the Trebia (218 BCE)",
		"Hannibal has come over the Alps with Gauls at his back. Sempronius is eager to fight "
		+ "and wades the icy Trebia to meet him. The center looks open — but Mago's Celts "
		+ "are hidden on your flank. Hold the riverbank or the Po valley is lost.",
		Vector2(0.47, 0.16),  # Po valley, north Italy
		NORMAL,
		[
			". e . . . . u .",
			"e . . E . . . u",
			". . . . . . . .",
			". . . . . . . .",
			". . . u u u . .",
			". . . . . . . .",
			". d d D d d . .",
			". . d . . d . .",
		],
		"res://audio/music/epic/Barca On The Alps.ogg"
	)


static func _trasimene() -> BattleData:
	return _battle(
		"trasimene",
		"Mission 4 - Battle of Lake Trasimene (217 BCE)",
		"Flaminius marches along the lake in the morning fog. Hannibal's Africans hold the "
		+ "road ahead; Gallic warbands wait on the hills above. The defile is a trap. "
		+ "Fight your way out before the water is at your back.",
		Vector2(0.46, 0.31),  # Lake Trasimene, Umbria
		NORMAL,
		[
			". . e e e e . .",
			". u e e E e u .",
			". . e e e e . .",
			". . . . . . . .",
			". . . . . . . .",
			". . . d d . . .",
			". . . d D d . .",
			". . . d d . . .",
		]
	)


static func _cannae() -> BattleData:
	return _battle(
		"cannae",
		"Mission 5 - Battle of Cannae (216 BCE)",
		"Two consular armies have cornered Hannibal on the Aufidus. His Gauls sag in the "
		+ "center; the African wings wait to close. If you drive too deep, the ring will "
		+ "shut. Break the crescent before it becomes a grave.",
		Vector2(0.61, 0.43),  # Apulia, the heel of Italy
		HARD,
		[
			"e e e . . u u u . . e e e",
			". e . . . . E . . . . e .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . d d d d d d d d d . .",
			"d d d d d d D d d d d d d",
		],
		"res://audio/music/epic/Cannae Ring.ogg"
	)


static func _metaurus() -> BattleData:
	return _battle(
		"metaurus",
		"Mission 6 - Battle of the Metaurus (207 BCE)",
		"Hasdrubal has crossed from Spain to join his brother. If the two armies meet, "
		+ "Italy falls. Intercept him on the Metaurus before Hannibal knows he has come. "
		+ "This is the last Gallic host Carthage will field on your soil.",
		Vector2(0.57, 0.25),  # Metauro, Marche / Adriatic Italy
		HARD,
		[
			"u u e e e e e e e e u u u",
			". . e . . . E . . . u . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . d d d d . d d d d . .",
			"d d d d d d D . . . . d d",
		]
	)


static func _zama() -> BattleData:
	return _battle(
		"zama",
		"Mission 7 - Battle of Zama (202 BCE)",
		"Scipio has carried the war to Africa. Hannibal is home, the Gauls are gone, "
		+ "and the elephants will come first. Meet him on the plain of Zama. Rome did not "
		+ "break at Cannae — do not break here.",
		Vector2(0.36, 0.78),  # inland Numidia, SW of Carthage
		HARD,
		[
			"e e e e e e e e e e e e e",
			". . e . . . E . . . e . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . d d d d . d d d d . .",
			"d d d d d d D . . . . d d",
		],
		"res://audio/music/epic/Rome Never Broke.ogg"
	)
