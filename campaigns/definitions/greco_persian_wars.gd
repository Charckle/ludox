extends RefCounted

# Greco-Persian Wars. All battles use XXI rules, human = player 2 (bottom).
# map_position is a UV on greek_persian_wars.png. Attica sites are nudged
# apart so Marathon / Salamis / Plataea do not stack at this zoom.
# City-state letters: see AsciiLayout. e/E stay Persian (campaign default).

const RULES_XXI := 2
const EASY := 0
const NORMAL := 1
const HARD := 2


static func build() -> CampaignData:
	var c := CampaignData.new()
	c.id = "greco_persian_wars"
	c.title = "Greco-Persian Wars"
	c.map_texture = preload("res://sprites/images/greek_persian_wars.png")
	c.cosmetics = {
		"1": {"faction": "persian", "color": "purple"},
		"2": {"faction": "athenian", "color": "blue"},
	}
	c.battles = [
		_sardis(),
		_marathon(),
		_thermopylae(),
		_salamis(),
		_plataea(),
		_mycale(),
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


static func _sardis() -> BattleData:
	return _battle(
		"sardis",
		"Mission 1 - Burning of Sardis (498 BCE)",
		"The Ionian cities have risen against the Great King. Milesians lead the strike on "
		+ "the satrapal capital of Lydia, with Athenian ships at their back. Burn Sardis "
		+ "and show Persia that Greece will not kneel.",
		Vector2(0.80, 0.40),  # inland Lydia, east of the Ionian coast
		EASY,
		[
			"e e e e e e e e",
			". . E . . . . .",
			". . . . . . . .",
			". . . . . . . .",
			". . . . . . . .",
			". . . . . . . .",
			". . . M . . . .",
			"m m m a a m m m",
		]
	)


static func _marathon() -> BattleData:
	return _battle(
		"marathon",
		"Mission 2 - Battle of Marathon (490 BCE)",
		"Darius has landed a host on the plain of Marathon, a day's march from Athens. "
		+ "Athenian hoplites hold the center; Plataeans take the wings. Charge the Persian "
		+ "line before they can bring their archers to bear.",
		Vector2(0.40, 0.48),  # east coast of Attica
		NORMAL,
		[
			"e e e e e e e e",
			"e . . E . . . e",
			". . . . . . . .",
			". . . . . . . .",
			". . . . . . . .",
			". . . . . . . .",
			". a a A a a . .",
			"p p . . . . p p",
		],
		"res://audio/music/epic/Marathon Plain.mp3"
	)


static func _thermopylae() -> BattleData:
	return _battle(
		"thermopylae",
		"Mission 3 - Battle of Thermopylae (480 BCE)",
		"Xerxes pours into Greece. Leonidas holds the Hot Gates with his Spartans; the "
		+ "Thespians stand with them. The pass is so narrow that numbers count for little. "
		+ "If it falls, the road to Athens lies open.",
		Vector2(0.30, 0.30),  # Malian Gulf, north of Attica
		HARD,
		[
			". e e e e e e .",
			". e e . E . e .",
			". e e e e e e .",
			". . . . . . . .",
			". . . . . . . .",
			". . . . . . . .",
			"h . s . . . s h",
			". s s s S s . .",
		]
	)


static func _salamis() -> BattleData:
	return _battle(
		"salamis",
		"Mission 4 - Battle of Salamis (480 BCE)",
		"Athens is evacuated. Themistocles packs the allied fleet into the strait — "
		+ "Athenian, Aeginetan, and Corinthian ships, with a Spartan among them. Persian "
		+ "and Ionian hulls crowd in after you. Break them before they envelop the channel.",
		Vector2(0.28, 0.54),  # island west of Athens
		NORMAL,
		[
			". i . . . . . . . . i .",
			"e . . e e E e e . . . e",
			". . . . . . . . . . . .",
			". . . . . . . . . . . .",
			". . . . e e e . . . . .",
			". . . . . . . . . . . .",
			". . . a a A a g . . . .",
			". c . . . . . . . . s .",
		]
	)


static func _plataea() -> BattleData:
	return _battle(
		"plataea",
		"Mission 5 - Battle of Plataea (479 BCE)",
		"Mardonius still holds Boeotia. On your left, Athens and Plataea; Corinthians "
		+ "in the center; Spartans on the right under Pausanias. Opposite the Athenians, "
		+ "Thebes has taken the Persian side. Drive the King from Greece — or lose the war.",
		Vector2(0.34, 0.41),  # Boeotia, NW of Athens
		HARD,
		[
			"b b b e e e e e e e e e e",
			". . b . . . E . . . e . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			". . . . . . . . . . . . .",
			"p a a a . c . s s s s . .",
			"p a a . c . s . S . s . .",
		],
		"res://audio/music/epic/At Plataea.mp3"
	)


static func _mycale() -> BattleData:
	return _battle(
		"mycale",
		"Mission 6 - Battle of Mycale (479 BCE)",
		"The invasion of Greece is broken, but a Persian force still holds the Ionian coast. "
		+ "Spartans and Athenians cross to Mycale; the Milesians rise with you. Storm the "
		+ "beached camp and finish the war on Asia's shore.",
		Vector2(0.70, 0.50),  # promontory opposite Samos
		HARD,
		[
			". . . . . . . .",
			". . e e E e e .",
			". . e e e e e .",
			". . . . . . . .",
			". . . . . . . .",
			". m . . . . . m",
			". . a a S a a .",
			"m m . . . . a a",
		]
	)
